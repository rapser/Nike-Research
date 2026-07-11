import UIKit

final class CartTotalCell: UITableViewCell {
    static let reuseID = "CartTotalCell"

    private let totalRow = LabelValueRow()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        totalRow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalRow)
        NSLayoutConstraint.activate([
            totalRow.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            totalRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            totalRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            totalRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(total: String) {
        totalRow.configure(label: "TOTAL", value: total)
    }
}
