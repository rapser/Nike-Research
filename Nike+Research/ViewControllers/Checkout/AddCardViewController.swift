import UIKit

final class AddCardViewController: UITableViewController {
    private let viewModel: AddCardViewModel

    private enum Row: Int, CaseIterable {
        case holderName, cardNumber, expiry, cvv, save
    }

    init(viewModel: AddCardViewModel) {
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
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Row(rawValue: indexPath.row)! {
        case .holderName:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "Cardholder Name", keyboardType: .default)
            cell.onTextChanged = { [weak self] text in self?.viewModel.holderName = text }
            return cell

        case .cardNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "Card Number (16 digits)", keyboardType: .numberPad)
            cell.onTextChanged = { [weak self] text in self?.viewModel.cardNumber = text }
            return cell

        case .expiry:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "Expiry (MM/YY)", keyboardType: .numberPad)
            cell.onTextChanged = { [weak self] text in self?.viewModel.expiryDate = text }
            return cell

        case .cvv:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: "CVV", keyboardType: .numberPad, isSecure: true)
            cell.onTextChanged = { [weak self] text in self?.viewModel.cvv = text }
            return cell

        case .save:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: "SAVE CARD")
            cell.onActionTapped = { [weak self] in self?.handleSave() }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    private func handleSave() {
        view.endEditing(true)
        guard viewModel.isValid else {
            let alert = UIAlertController(title: "Incomplete",
                                          message: "Please fill in all fields.\nCard number must be 16 digits, expiry MM/YY, CVV 3+ digits.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        viewModel.saveCard()
    }
}
