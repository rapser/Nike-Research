import UIKit

final class OrderItemCell: UITableViewCell {
    static let reuseID = "OrderItemCell"

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let qtyLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 12) ?? .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let totalLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-Medium", size: 14) ?? .systemFont(ofSize: 14)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(nameLabel)
        contentView.addSubview(qtyLabel)
        contentView.addSubview(totalLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: totalLabel.leadingAnchor, constant: -8),

            qtyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            qtyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            qtyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            totalLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(name: String, quantity: Int, lineTotal: String) {
        nameLabel.text = name
        qtyLabel.text = "\(String(localized: "Qty:")) \(quantity)"
        totalLabel.text = lineTotal
    }
}
