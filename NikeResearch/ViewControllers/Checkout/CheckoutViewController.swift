import UIKit

final class CheckoutViewController: UITableViewController {
    private let viewModel: CheckoutViewModel

    private enum Row: Int, CaseIterable {
        case orderTitle, summary, total, paymentTitle, paymentCard, placeOrder
    }

    init(viewModel: CheckoutViewModel) {
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
        tableView.register(BillingTitleCell.self, forCellReuseIdentifier: BillingTitleCell.reuseID)
        tableView.register(CartSummaryCell.self, forCellReuseIdentifier: CartSummaryCell.reuseID)
        tableView.register(CartTotalCell.self, forCellReuseIdentifier: CartTotalCell.reuseID)
        tableView.register(PaymentCardCell.self, forCellReuseIdentifier: PaymentCardCell.reuseID)
        tableView.register(ActionButtonCell.self, forCellReuseIdentifier: ActionButtonCell.reuseID)

        viewModel.onSelectionChanged = { [weak self] in
            guard let self else { return }
            let rows = [IndexPath(row: Row.paymentCard.rawValue, section: 0),
                        IndexPath(row: Row.placeOrder.rawValue, section: 0)]
            self.tableView.reloadRows(at: rows, with: .none)
        }
        viewModel.onCheckoutFailed = { [weak self] error in
            self?.setPlacingOrder(false)
            self?.presentAlert(title: String(localized: "Couldn't Place Order"), message: error.localizedDescription)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Row(rawValue: indexPath.row)! {
        case .orderTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingTitleCell.reuseID, for: indexPath) as! BillingTitleCell
            cell.configure(title: String(localized: "ORDER SUMMARY"))
            return cell

        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartSummaryCell.reuseID, for: indexPath) as! CartSummaryCell
            cell.configure(subtotal: viewModel.subtotalText, shipping: viewModel.shippingText, tax: viewModel.taxText)
            return cell

        case .total:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartTotalCell.reuseID, for: indexPath) as! CartTotalCell
            cell.configure(total: viewModel.totalText)
            return cell

        case .paymentTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingTitleCell.reuseID, for: indexPath) as! BillingTitleCell
            cell.configure(title: String(localized: "PAYMENT METHOD"))
            return cell

        case .paymentCard:
            let cell = tableView.dequeueReusableCell(withIdentifier: PaymentCardCell.reuseID, for: indexPath) as! PaymentCardCell
            cell.configureSelector(title: viewModel.selectedCardTitle, subtitle: viewModel.selectedCardSubtitle)
            return cell

        case .placeOrder:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: String(localized: "PLACE ORDER"), enabled: viewModel.isFormValid)
            cell.onActionTapped = { [weak self] in self?.handlePlaceOrder() }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if Row(rawValue: indexPath.row) == .paymentCard {
            viewModel.selectPaymentTapped()
        }
    }

    private func handlePlaceOrder() {
        guard viewModel.isFormValid else {
            presentAlert(title: String(localized: "No Payment Method"), message: String(localized: "Please select a payment method before placing your order."))
            return
        }
        setPlacingOrder(true)
        viewModel.placeOrder()
    }

    private func setPlacingOrder(_ placing: Bool) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: Row.placeOrder.rawValue, section: 0)) as? ActionButtonCell else { return }
        cell.configure(title: placing ? String(localized: "PLACING ORDER...") : String(localized: "PLACE ORDER"), enabled: !placing && viewModel.isFormValid)
    }
}
