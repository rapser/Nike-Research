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
        tableView.register(CardNumberCell.self, forCellReuseIdentifier: CardNumberCell.reuseID)
        tableView.register(ExpiryDateCell.self, forCellReuseIdentifier: ExpiryDateCell.reuseID)
        tableView.register(ActionButtonCell.self, forCellReuseIdentifier: ActionButtonCell.reuseID)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Row(rawValue: indexPath.row)! {
        case .holderName:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: String(localized: "Cardholder Name"), keyboardType: .default)
            cell.onTextChanged = { [weak self] text in self?.viewModel.holderName = text }
            return cell

        case .cardNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: CardNumberCell.reuseID, for: indexPath) as! CardNumberCell
            cell.configure(number: viewModel.cardNumber)
            cell.onNumberChanged = { [weak self] number in self?.viewModel.cardNumber = number }
            return cell

        case .expiry:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpiryDateCell.reuseID, for: indexPath) as! ExpiryDateCell
            cell.configure(month: viewModel.expiryMonth, year: viewModel.expiryYear)
            cell.onExpiryChanged = { [weak self] month, year in self?.viewModel.updateExpiry(month: month, year: year) }
            return cell

        case .cvv:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
            cell.configure(placeholder: String(localized: "CVV"), keyboardType: .numberPad, isSecure: true)
            cell.onTextChanged = { [weak self] text in self?.viewModel.cvv = text }
            return cell

        case .save:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: String(localized: "SAVE CARD"))
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
            presentAlert(title: String(localized: "Incomplete"), message: String(localized: "Please fill in the cardholder name, a valid card number, and a CVV of 3 or more digits."))
            return
        }
        setLoading(true)
        viewModel.saveCard { [weak self] error in
            self?.setLoading(false)
            if let error {
                self?.presentAlert(title: String(localized: "Couldn't Save Card"), message: error.localizedDescription)
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: Row.save.rawValue, section: 0)) as? ActionButtonCell else { return }
        cell.configure(title: loading ? String(localized: "SAVING...") : String(localized: "SAVE CARD"), enabled: !loading)
    }
}
