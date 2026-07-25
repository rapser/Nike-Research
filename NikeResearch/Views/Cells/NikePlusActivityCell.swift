import UIKit

final class NikePlusActivityCell: UITableViewCell {
    static let reuseID = "NikePlusActivityCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 11) ?? .systemFont(ofSize: 11)
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 36) ?? .boldSystemFont(ofSize: 36)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let unitLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .darkGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(unitLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            unitLabel.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            unitLabel.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 6),

            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        let separator = UIView()
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, value: String, unit: String) {
        titleLabel.text = title
        valueLabel.text = value
        unitLabel.text = unit
    }
}
