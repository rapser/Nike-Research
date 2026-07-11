import UIKit

final class RegisterViewController: UITableViewController {
    private let viewModel: RegisterViewModel
    var onRegisterSuccess: (() -> Void)?
    var onLogInTapped: (() -> Void)?

    private enum Row: Int, CaseIterable {
        case name, email, password, confirmPassword, register, logInPrompt
    }

    init(viewModel: RegisterViewModel) {
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
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "Full Name", text: viewModel.name, keyboardType: .default)
            cell.onTextChanged = { [weak self] text in self?.viewModel.name = text }
            return cell

        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "Email", text: viewModel.email, keyboardType: .emailAddress)
            cell.textField.autocapitalizationType = .none
            cell.onTextChanged = { [weak self] text in self?.viewModel.email = text }
            return cell

        case .password:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "Password", text: viewModel.password, keyboardType: .default, isSecure: true)
            cell.onTextChanged = { [weak self] text in self?.viewModel.password = text }
            return cell

        case .confirmPassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "Confirm Password", text: viewModel.confirmPassword, keyboardType: .default, isSecure: true)
            cell.onTextChanged = { [weak self] text in self?.viewModel.confirmPassword = text }
            return cell

        case .register:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: "CREATE ACCOUNT")
            cell.onActionTapped = { [weak self] in self?.handleRegister() }
            return cell

        case .logInPrompt:
            let cell = tableView.dequeueReusableCell(withIdentifier: AuthLinkCell.reuseID, for: indexPath) as! AuthLinkCell
            cell.configure(prompt: "Already have an account?", actionTitle: "LOG IN")
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if Row(rawValue: indexPath.row) == .logInPrompt {
            view.endEditing(true)
            onLogInTapped?()
        }
    }

    private func handleRegister() {
        view.endEditing(true)
        guard viewModel.isValid else {
            presentAlert(message: "Please fill in all fields. Password must be at least 6 characters and match its confirmation.")
            return
        }
        setLoading(true)
        viewModel.register { [weak self] error in
            self?.setLoading(false)
            if let error = error {
                self?.presentAlert(message: error.localizedDescription)
            } else {
                self?.onRegisterSuccess?()
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: Row.register.rawValue, section: 0)) as? ActionButtonCell else { return }
        cell.configure(title: loading ? "CREATING ACCOUNT..." : "CREATE ACCOUNT", enabled: !loading)
    }

    private func presentAlert(message: String) {
        let alert = UIAlertController(title: "Couldn't Create Account", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
