import UIKit

final class MyOrdersViewController: UIViewController {
    private let viewModel: MyOrdersViewModel
    var onOrderSelected: ((Order) -> Void)?

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 70
        tv.register(OrderHistoryCell.self, forCellReuseIdentifier: OrderHistoryCell.reuseID)
        return tv
    }()

    private lazy var emptyView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 48, weight: .ultraLight)
        let icon = UIImageView(image: UIImage(systemName: "bag", withConfiguration: cfg))
        icon.tintColor = UIColor.black.withAlphaComponent(0.15)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = String(localized: "NO ORDERS YET")
        label.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = String(localized: "Your completed orders will appear here.")
        sub.font = UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
        sub.textColor = .gray
        sub.textAlignment = .center
        sub.numberOfLines = 0
        sub.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(icon)
        container.addSubview(label)
        container.addSubview(sub)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -40),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            sub.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            sub.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            sub.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
        ])
        return container
    }()

    init(viewModel: MyOrdersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.onOrdersChanged = { [weak self] in self?.refresh() }
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadOrders { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Load Orders"), message: error.localizedDescription)
            }
            self.refresh()
        }
    }

    private func refresh() {
        tableView.reloadData()
        emptyView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
    }
}

extension MyOrdersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryCell.reuseID, for: indexPath) as! OrderHistoryCell
        let order = viewModel.order(at: indexPath.row)
        cell.configure(number: order.number, date: order.formattedDate, total: order.formattedTotal)
        return cell
    }
}

extension MyOrdersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onOrderSelected?(viewModel.order(at: indexPath.row))
    }
}
