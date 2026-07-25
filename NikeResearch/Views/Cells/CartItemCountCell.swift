import UIKit

final class CartItemCountCell: UITableViewCell {
    static let reuseID = "CartItemCountCell"

    private let countLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .boldSystemFont(ofSize: 17)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(countLabel)
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String) {
        countLabel.text = text
    }
}
