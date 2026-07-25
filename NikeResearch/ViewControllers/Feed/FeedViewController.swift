import UIKit

final class FeedViewController: UIViewController {
    private let viewModel: FeedViewModel

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 400
        tv.register(FeedShoeCell.self, forCellReuseIdentifier: FeedShoeCell.reuseID)
        return tv
    }()

    private let loadingView = LoadingOverlayView()

    init(viewModel: FeedViewModel) {
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
        loadingView.pin(to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.onStateChanged = { [weak self] in
            self?.render()
        }
        loadShoes()
    }

    private func loadShoes() {
        viewModel.loadShoes { [weak self] error in
            guard let self, let error else { return }
            self.presentAlert(title: String(localized: "Couldn't Load Products"), message: error.localizedDescription)
        }
    }

    private func render() {
        loadingView.isLoading = viewModel.state == .loading
        tableView.reloadData()
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.shoeCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedShoeCell.reuseID, for: indexPath) as! FeedShoeCell
        let shoe = viewModel.shoe(at: indexPath.row)
        cell.configure(image: shoe.images.first, name: shoe.name, price: shoe.formattedPrice)
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectShoe(at: indexPath.row)
    }
}
