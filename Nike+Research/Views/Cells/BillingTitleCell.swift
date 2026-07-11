import UIKit

final class BillingTitleCell: UITableViewCell {
    static let reuseID = "BillingTitleCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 15) ?? .boldSystemFont(ofSize: 15)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) { textLabel?.text = title }
}
