import UIKit

final class MyAddressesViewController: UIViewController {
    private let viewModel: MyAddressesViewModel
    private let loadingView = LoadingOverlayView()
    var onAddAddress: (() -> Void)?
    var onEditAddress: ((Address) -> Void)?

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 70
        tv.register(AddressCell.self, forCellReuseIdentifier: AddressCell.reuseID)
        return tv
    }()

    private lazy var emptyView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 48, weight: .ultraLight)
        let icon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse", withConfiguration: cfg))
        icon.tintColor = UIColor.black.withAlphaComponent(0.15)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = String(localized: "NO ADDRESSES YET")
        label.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = String(localized: "Add a shipping address to speed up checkout.")
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

    init(viewModel: MyAddressesViewModel) {
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
        loadingView.pin(to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.onAddressesChanged = { [weak self] in self?.refresh() }
        viewModel.onStateChanged = { [weak self] in self?.refresh() }
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadAddresses { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Load Addresses"), message: error.localizedDescription)
            }
            self.refresh()
        }
    }

    private func refresh() {
        tableView.reloadData()
        // El empty state solo aparece cuando la respuesta llegó vacía de verdad, no
        // mientras la petición sigue en vuelo.
        loadingView.isLoading = viewModel.state == .loading
        emptyView.isHidden = viewModel.state != .empty
        tableView.isHidden = viewModel.state == .empty
    }

    @objc private func addTapped() { onAddAddress?() }
}

extension MyAddressesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.reuseID, for: indexPath) as! AddressCell
        cell.configure(address: viewModel.address(at: indexPath.row))
        return cell
    }
}

extension MyAddressesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.remove(at: indexPath.row) { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Remove Address"), message: error.localizedDescription)
                tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if self.viewModel.isEmpty { self.refresh() }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onEditAddress?(viewModel.address(at: indexPath.row))
    }
}
