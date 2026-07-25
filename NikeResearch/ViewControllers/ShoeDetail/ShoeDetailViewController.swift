import UIKit

final class ShoeDetailViewController: UIViewController {
    private let viewModel: ShoeDetailViewModel
    var onSuggestionSelected: ((Shoe) -> Void)?

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.register(ShoeDetailInfoCell.self, forCellReuseIdentifier: ShoeDetailInfoCell.reuseID)
        tv.register(BuyButtonCell.self, forCellReuseIdentifier: BuyButtonCell.reuseID)
        tv.register(ProductDetailsCell.self, forCellReuseIdentifier: ProductDetailsCell.reuseID)
        tv.register(SuggestionTableCell.self, forCellReuseIdentifier: SuggestionTableCell.reuseID)
        return tv
    }()

    private let headerView = ImageCarouselHeaderView()
    private var pageViewController: ShoeImagesPageViewController?

    init(viewModel: ShoeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        setupFavoriteButton()
        tableView.dataSource = self
        tableView.delegate = self
        if !viewModel.images.isEmpty {
            setupHeader()
        }
        viewModel.onQuantityChanged = { [weak self] in
            self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
        loadSuggestions()
    }

    private func loadSuggestions() {
        viewModel.loadSuggestions { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Load Products"), message: error.localizedDescription)
                return
            }
            // `reloadData` y no `reloadRows`: si el catálogo ya estaba cacheado esto
            // corre síncrono dentro de `viewDidLoad`, antes del primer layout de la
            // tabla, y recargar una fila suelta ahí no es seguro. Hace falta recargar
            // —no solo la collection interna— porque el alto de la fila depende de
            // `suggestionCount`.
            self.tableView.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewModel.images.isEmpty {
            sizeHeaderToFit()
        }
    }

    private func setupFavoriteButton() {
        let isFav = viewModel.isFavorite
        let image = UIImage(named: isFav ? "heart.fill" : "heart") ?? heartImage(filled: isFav)
        let favBtn = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(favoriteTapped))
        navigationItem.rightBarButtonItem = favBtn
    }

    @objc private func favoriteTapped() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        viewModel.toggleFavorite { [weak self] error in
            guard let self else { return }
            self.setupFavoriteButton()
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Update Favorites"), message: error.localizedDescription)
            }
        }
    }

    private var buyButtonCell: BuyButtonCell? {
        tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BuyButtonCell
    }

    private func handleBuyTapped() {
        buyButtonCell?.setLoading(true)
        viewModel.addToCartTapped { [weak self] _ in
            self?.buyButtonCell?.setLoading(false)
        }
    }

    private func setupHeader() {
        headerView.pageControl.numberOfPages = viewModel.images.count

        let pageVC = ShoeImagesPageViewController(images: viewModel.images)
        pageVC.onPageChanged = { [weak self] index in
            self?.headerView.pageControl.currentPage = index
        }

        addChild(pageVC)
        headerView.carouselContainer.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: headerView.carouselContainer.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: headerView.carouselContainer.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: headerView.carouselContainer.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: headerView.carouselContainer.bottomAnchor)
        ])
        pageVC.didMove(toParent: self)
        pageViewController = pageVC

        tableView.tableHeaderView = headerView
    }

    private func sizeHeaderToFit() {
        let width = view.bounds.width
        let pageControlHeight: CGFloat = 36
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: width + pageControlHeight)
        tableView.tableHeaderView = headerView
    }

    private func heartImage(filled: Bool) -> UIImage {
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        return UIImage(systemName: filled ? "heart.fill" : "heart", withConfiguration: cfg) ?? UIImage()
    }
}

// MARK: - UITableViewDataSource

extension ShoeDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 4 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ShoeDetailInfoCell.reuseID, for: indexPath) as! ShoeDetailInfoCell
            cell.configure(name: viewModel.name, description: viewModel.description)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: BuyButtonCell.reuseID, for: indexPath) as! BuyButtonCell
            cell.configure(title: viewModel.buyButtonTitle, quantity: viewModel.quantityText)
            cell.onDecrementTapped = { [weak self] in self?.viewModel.decrementQuantity() }
            cell.onIncrementTapped = { [weak self] in self?.viewModel.incrementQuantity() }
            cell.onBuyTapped = { [weak self] in self?.handleBuyTapped() }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductDetailsCell.reuseID, for: indexPath) as! ProductDetailsCell
            cell.configure(detail: viewModel.detail)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionTableCell.reuseID, for: indexPath) as! SuggestionTableCell
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension ShoeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            // Sin sugerencias todavía (o si fallaron) la fila se colapsa, en vez de
            // reservar el alto del título para una rejilla vacía.
            guard viewModel.suggestionCount > 0 else { return 0 }
            let itemWidth = (view.bounds.width - 10 - 5) / 2
            let rows = ceil(Double(viewModel.suggestionCount) / 2.0)
            let labelHeight: CGFloat = 60
            let titleHeight: CGFloat = 40
            return CGFloat(rows) * (itemWidth + labelHeight) + CGFloat(rows - 1) * 5 + titleHeight + 24
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UICollectionViewDataSource

extension ShoeDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.suggestionCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestionCollectionCell.reuseID, for: indexPath) as! SuggestionCollectionCell
        cell.configure(
            image: viewModel.suggestionImage(at: indexPath.item),
            name: viewModel.suggestionName(at: indexPath.item),
            price: viewModel.suggestionPrice(at: indexPath.item)
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegate + FlowLayout

extension ShoeDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shoe = viewModel.suggestions[indexPath.item]
        onSuggestionSelected?(shoe)
    }
}

extension ShoeDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalPadding: CGFloat = 10 + 2.5
        let width = (collectionView.bounds.width - totalPadding) / 2
        let labelHeight: CGFloat = 60
        return CGSize(width: width, height: width + labelHeight)
    }
}
