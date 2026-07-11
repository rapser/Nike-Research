import UIKit

final class FavoritesViewController: UIViewController {
    private let viewModel: FavoritesViewModel
    var onShoeSelected: ((Shoe) -> Void)?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.register(FavoriteShoeCell.self, forCellWithReuseIdentifier: FavoriteShoeCell.reuseID)
        return cv
    }()

    private lazy var emptyView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let heartView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 48, weight: .ultraLight)
        heartView.image = UIImage(systemName: "heart", withConfiguration: cfg)
        heartView.tintColor = UIColor.black.withAlphaComponent(0.15)
        heartView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "NO FAVORITES YET"
        label.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "Tap the heart on any shoe to save it here."
        sub.font = UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
        sub.textColor = .gray
        sub.textAlignment = .center
        sub.numberOfLines = 0
        sub.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(heartView)
        container.addSubview(label)
        container.addSubview(sub)
        NSLayoutConstraint.activate([
            heartView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            heartView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -40),
            label.topAnchor.constraint(equalTo: heartView.bottomAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            sub.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            sub.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            sub.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
        ])
        return container
    }()

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        collectionView.dataSource = self
        collectionView.delegate = self
        viewModel.onFavoritesChanged = { [weak self] in
            self?.refresh()
        }
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    private func refresh() {
        collectionView.reloadData()
        emptyView.isHidden = !viewModel.isEmpty
        collectionView.isHidden = viewModel.isEmpty
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteShoeCell.reuseID, for: indexPath) as! FavoriteShoeCell
        let shoe = viewModel.shoe(at: indexPath.item)
        cell.configure(image: shoe.images.first, name: shoe.name, price: shoe.formattedPrice)
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shoe = viewModel.shoe(at: indexPath.item)
        onShoeSelected?(shoe)
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 1) / 2
        return CGSize(width: width, height: width + 60)
    }
}
