import UIKit

final class AddressCell: UITableViewCell {
    static let reuseID = "AddressCell"

    private let streetLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 15) ?? .boldSystemFont(ofSize: 15)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let detailLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .darkGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let iconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        let iv = UIImageView(image: UIImage(systemName: "mappin.circle", withConfiguration: cfg))
        iv.tintColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(iconView)
        contentView.addSubview(streetLabel)
        contentView.addSubview(detailLabel)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),

            streetLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            streetLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            streetLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            detailLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: streetLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: streetLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(address: Address) {
        streetLabel.text = address.displayTitle
        detailLabel.text = address.displaySubtitle
    }
}
