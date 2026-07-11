import UIKit

final class OrderHistoryCell: UITableViewCell {
    static let reuseID = "OrderHistoryCell"

    private let numberLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 16) ?? .boldSystemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .darkGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let totalLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-Medium", size: 15) ?? .systemFont(ofSize: 15)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        contentView.addSubview(numberLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(totalLabel)
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            numberLabel.trailingAnchor.constraint(equalTo: totalLabel.leadingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            totalLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(number: String, date: String, total: String) {
        numberLabel.text = number
        dateLabel.text = date
        totalLabel.text = total
    }
}
