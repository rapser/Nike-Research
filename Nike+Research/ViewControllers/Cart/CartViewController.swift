import UIKit

final class CartViewController: UITableViewController {
    private let viewModel: CartViewModel

    private enum Section: Int, CaseIterable {
        case header, items, empty, summary, total, checkout
    }

    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) { fatalError() }

    private lazy var clearButton = UIBarButtonItem(title: String(localized: "Clear"), style: .plain, target: self, action: #selector(clearTapped))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(CartItemCountCell.self, forCellReuseIdentifier: CartItemCountCell.reuseID)
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseID)
        tableView.register(CartEmptyStateCell.self, forCellReuseIdentifier: CartEmptyStateCell.reuseID)
        tableView.register(CartSummaryCell.self, forCellReuseIdentifier: CartSummaryCell.reuseID)
        tableView.register(CartTotalCell.self, forCellReuseIdentifier: CartTotalCell.reuseID)
        tableView.register(ActionButtonCell.self, forCellReuseIdentifier: ActionButtonCell.reuseID)
        navigationItem.rightBarButtonItem = clearButton

        viewModel.onCartChanged = { [weak self] in
            self?.updateClearButton()
            self?.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCart { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Load Cart"), message: error.localizedDescription)
            }
            self.updateClearButton()
            self.tableView.reloadData()
        }
    }

    private func updateClearButton() {
        clearButton.isEnabled = !viewModel.isEmpty
    }

    @objc private func clearTapped() {
        let alert = UIAlertController(title: String(localized: "Clear Cart"), message: String(localized: "Remove all items from your cart?"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: String(localized: "Clear"), style: .destructive) { [weak self] _ in
            self?.viewModel.clearCart { error in
                if let error {
                    self?.presentAlert(title: String(localized: "Couldn't Clear Cart"), message: error.localizedDescription)
                }
            }
        })
        present(alert, animated: true)
    }

    // MARK: - DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:   return 1
        case .items:    return viewModel.isEmpty ? 0 : viewModel.itemCount
        case .empty:    return viewModel.isEmpty ? 1 : 0
        case .summary:  return viewModel.isEmpty ? 0 : 1
        case .total:    return viewModel.isEmpty ? 0 : 1
        case .checkout: return viewModel.isEmpty ? 0 : 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCountCell.reuseID, for: indexPath) as! CartItemCountCell
            cell.configure(text: viewModel.itemCountText)
            return cell

        case .items:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseID, for: indexPath) as! CartItemCell
            let item = viewModel.items[indexPath.row]
            cell.configure(image: item.shoe.images.first, name: item.shoe.name,
                           price: item.shoe.formattedPrice, quantity: item.quantity)
            let idx = indexPath.row
            cell.onDecrementTapped = { [weak self] in
                self?.viewModel.decrementQuantity(at: idx) { error in
                    if let error {
                        self?.presentAlert(title: String(localized: "Couldn't Update Quantity"), message: error.localizedDescription)
                    }
                }
            }
            cell.onIncrementTapped = { [weak self] in
                self?.viewModel.incrementQuantity(at: idx) { error in
                    if let error {
                        self?.presentAlert(title: String(localized: "Couldn't Update Quantity"), message: error.localizedDescription)
                    }
                }
            }
            cell.onRemoveTapped = { [weak self] in
                self?.viewModel.removeItem(at: idx) { error in
                    if let error {
                        self?.presentAlert(title: String(localized: "Couldn't Remove Item"), message: error.localizedDescription)
                    }
                }
            }
            return cell

        case .empty:
            return tableView.dequeueReusableCell(withIdentifier: CartEmptyStateCell.reuseID, for: indexPath) as! CartEmptyStateCell

        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartSummaryCell.reuseID, for: indexPath) as! CartSummaryCell
            cell.configure(subtotal: viewModel.subtotalText, shipping: viewModel.shippingText, tax: viewModel.taxText)
            return cell

        case .total:
            let cell = tableView.dequeueReusableCell(withIdentifier: CartTotalCell.reuseID, for: indexPath) as! CartTotalCell
            cell.configure(total: viewModel.totalText)
            return cell

        case .checkout:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: String(localized: "CHECKOUT"))
            cell.onActionTapped = { [weak self] in self?.viewModel.checkoutTapped() }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
