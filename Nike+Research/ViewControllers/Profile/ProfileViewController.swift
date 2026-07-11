import UIKit

final class ProfileViewController: UIViewController {
    private let viewModel: ProfileViewModel
    var onMyCardsTapped: (() -> Void)?
    var onMyOrdersTapped: (() -> Void)?
    var onMyAddressesTapped: (() -> Void)?
    var onLoginTapped: (() -> Void)?
    var onSignUpTapped: (() -> Void)?
    var onLogoutTapped: (() -> Void)?

    private enum Row {
        case myCards, myOrders, myAddresses, logOut
        case login, signUp
    }

    private var rows: [Row] {
        viewModel.isAuthenticated
            ? [.myCards, .myOrders, .myAddresses, .logOut]
            : [.login, .signUp]
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        tv.register(ProfileMenuCell.self, forCellReuseIdentifier: ProfileMenuCell.reuseID)
        tv.register(ActionButtonCell.self, forCellReuseIdentifier: ActionButtonCell.reuseID)
        return tv
    }()

    init(viewModel: ProfileViewModel) {
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
        tableView.dataSource = self
        tableView.delegate = self
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func refresh() {
        tableView.tableHeaderView = makeHeaderView()
        tableView.reloadData()
    }

    private func makeHeaderView() -> UIView {
        viewModel.isAuthenticated ? makeSignedInHeaderView() : makeSignedOutHeaderView()
    }

    private func makeSignedInHeaderView() -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 160))
        container.backgroundColor = .white

        let avatarView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 42, weight: .thin)
        avatarView.image = UIImage(systemName: "person.circle", withConfiguration: cfg)
        avatarView.tintColor = .black
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = viewModel.memberName
        nameLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22) ?? .boldSystemFont(ofSize: 22)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let emailLabel = UILabel()
        emailLabel.text = viewModel.memberEmail
        emailLabel.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        emailLabel.textColor = .gray
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        let sinceLabel = UILabel()
        sinceLabel.text = viewModel.memberSince
        sinceLabel.font = UIFont(name: "AvenirNext-Regular", size: 12) ?? .systemFont(ofSize: 12)
        sinceLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        sinceLabel.textAlignment = .center
        sinceLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(avatarView)
        container.addSubview(nameLabel)
        container.addSubview(emailLabel)
        container.addSubview(sinceLabel)

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            avatarView.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            sinceLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 2),
            sinceLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        return container
    }

    private func makeSignedOutHeaderView() -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 180))
        container.backgroundColor = .white

        let iconView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 48, weight: .thin)
        iconView.image = UIImage(systemName: "person.circle", withConfiguration: cfg)
        iconView.tintColor = UIColor.black.withAlphaComponent(0.4)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Join Us"
        titleLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22) ?? .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Log in to see your orders, cards and addresses."
        subtitleLabel.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32)
        ])
        return container
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .myCards:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.reuseID, for: indexPath) as! ProfileMenuCell
            cell.configure(title: "MY CARDS", sfSymbol: "creditcard")
            return cell
        case .myOrders:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.reuseID, for: indexPath) as! ProfileMenuCell
            cell.configure(title: "MY ORDERS", sfSymbol: "bag")
            return cell
        case .myAddresses:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.reuseID, for: indexPath) as! ProfileMenuCell
            cell.configure(title: "MY ADDRESSES", sfSymbol: "location")
            return cell
        case .logOut:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.reuseID, for: indexPath) as! ProfileMenuCell
            cell.configure(title: "LOG OUT", sfSymbol: "rectangle.portrait.and.arrow.right")
            return cell
        case .login:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: "LOG IN", style: .primary)
            cell.onActionTapped = { [weak self] in self?.onLoginTapped?() }
            return cell
        case .signUp:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: "SIGN UP", style: .outline)
            cell.onActionTapped = { [weak self] in self?.onSignUpTapped?() }
            return cell
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .myCards: onMyCardsTapped?()
        case .myOrders: onMyOrdersTapped?()
        case .myAddresses: onMyAddressesTapped?()
        case .logOut: onLogoutTapped?()
        case .login, .signUp: break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch rows[indexPath.row] {
        case .login, .signUp: return UITableView.automaticDimension
        default: return 60
        }
    }
}
