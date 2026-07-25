import UIKit

final class CartSummaryCell: UITableViewCell {
    static let reuseID = "CartSummaryCell"

    private let subtotalRow = LabelValueRow()
    private let shippingRow = LabelValueRow()
    private let taxRow = LabelValueRow()

    private lazy var stack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [subtotalRow, shippingRow, taxRow])
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(subtotal: String, shipping: String, tax: String) {
        subtotalRow.configure(label: String(localized: "SUBTOTAL"), value: subtotal)
        shippingRow.configure(label: String(localized: "ESTIMATED SHIPPING"), value: shipping)
        taxRow.configure(label: String(localized: "TAX"), value: tax)
    }
}

final class LabelValueRow: UIView {
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .darkGray
        return l
    }()
    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Medium", size: 13) ?? .systemFont(ofSize: 13)
        l.textAlignment = .right
        return l
    }()

    init() {
        super.init(frame: .zero)
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(label: String, value: String) {
        titleLabel.text = label
        valueLabel.text = value
    }
}
