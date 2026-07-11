import UIKit

final class OrderDetailViewController: UITableViewController {
    private let viewModel: OrderDetailViewModel

    private enum Section: Int, CaseIterable {
        case info, items, payment, summary, total
    }

    init(viewModel: OrderDetailViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(BillingTitleCell.self, forCellReuseIdentifier: BillingTitleCell.reuseID)
        tableView.register(OrderItemCell.self, forCellReuseIdentifier: OrderItemCell.reuseID)
        tableView.register(PaymentCardCell.self, forCellReuseIdentifier: PaymentCardCell.reuseID)
        tableView.register(CartSummaryCell.self, forCellReuseIdentifier: CartSummaryCell.reuseID)
        tableView.register(CartTotalCell.self, forCellReuseIdentifier: CartTotalCell.reuseID)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .info:    return 1
        case .items:   return viewModel.itemCount
        case .payment: return 1
        case .summary: return 1
        case .total:   return 1
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .white
        let label = UILabel()
        label.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 13) ?? .boldSystemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        switch Section(rawValue: section)! {
        case .info:    label.text = "ORDER DETAILS"
        case .items:   label.text = "ITEMS"
        case .payment: label.text = "PAYMENT"
        case .summary: label.text = "SUMMARY"
        case .total:   return nil
        }
        header.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 24),
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Section(rawValue: section) == .total ? 0 : 32
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingTitleCell.reuseID, for: indexPath) as! BillingTitleCell
            cell.configure(title: "\(viewModel.date)\n\(viewModel.estimatedDelivery)")
            cell.textLabel?.numberOfLines = 0
            return cell

        case .items:
            let cell = tableView.dequeueReusableCell(withIdentifier: OrderItemCell.reuseID, for: indexPath) as! OrderItemCell
            let item = viewModel.item(at: indexPath.row)
            cell.configure(name: item.shoeName, quantity: item.quantity, lineTotal: item.formattedLineTotal)
            return cell

        case .payment:
            let cell = tableView.dequeueReusableCell(withIdentifier: PaymentCardCell.reuseID, for: indexPath) as! PaymentCardCell
            cell.configureSelector(title: viewModel.paymentDisplay, subtitle: viewModel.paymentSubtitle)
            cell.accessoryType = .none
            return cell

        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartSummaryCell.reuseID, for: indexPath) as! CartSummaryCell
            cell.configure(subtotal: viewModel.subtotalText, shipping: viewModel.shippingText, tax: viewModel.taxText)
            return cell

        case .total:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartTotalCell.reuseID, for: indexPath) as! CartTotalCell
            cell.configure(total: viewModel.totalText)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
