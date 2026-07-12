import UIKit

final class LoginViewController: UITableViewController {
    private let viewModel: LoginViewModel
    var onLoginSuccess: (() -> Void)?
    var onSignUpTapped: (() -> Void)?

    private enum Row: Int, CaseIterable {
        case email, password, login, signUpPrompt
    }

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.keyboardDismissMode = .onDrag
        tableView.register(BillingFormCell.self, forCellReuseIdentifier: BillingFormCell.reuseID)
        tableView.register(ActionButtonCell.self, forCellReuseIdentifier: ActionButtonCell.reuseID)
        tableView.register(AuthLinkCell.self, forCellReuseIdentifier: AuthLinkCell.reuseID)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Row(rawValue: indexPath.row)! {
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: String(localized: "Email"), text: viewModel.email, keyboardType: .emailAddress)
            cell.textField.autocapitalizationType = .none
            cell.onTextChanged = { [weak self] text in self?.viewModel.email = text }
            return cell

        case .password:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: String(localized: "Password"), text: viewModel.password, keyboardType: .default, isSecure: true)
            cell.onTextChanged = { [weak self] text in self?.viewModel.password = text }
            return cell

        case .login:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: String(localized: "LOG IN"))
            cell.onActionTapped = { [weak self] in self?.handleLogin() }
            return cell

        case .signUpPrompt:
            let cell = tableView.dequeueReusableCell(withIdentifier: AuthLinkCell.reuseID, for: indexPath) as! AuthLinkCell
            cell.configure(prompt: String(localized: "Don't have an account?"), actionTitle: String(localized: "SIGN UP"))
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if Row(rawValue: indexPath.row) == .signUpPrompt {
            view.endEditing(true)
            onSignUpTapped?()
        }
    }

    private func handleLogin() {
        view.endEditing(true)
        guard viewModel.isValid else {
            presentAlert(title: String(localized: "Couldn't Log In"), message: String(localized: "Please enter a valid email and a password with at least 6 characters."))
            return
        }
        setLoading(true)
        viewModel.login { [weak self] error in
            self?.setLoading(false)
            if let error = error {
                self?.presentAlert(title: String(localized: "Couldn't Log In"), message: error.localizedDescription)
            } else {
                self?.onLoginSuccess?()
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: Row.login.rawValue, section: 0)) as? ActionButtonCell else { return }
        cell.configure(title: loading ? String(localized: "LOGGING IN...") : String(localized: "LOG IN"), enabled: !loading)
    }
}
