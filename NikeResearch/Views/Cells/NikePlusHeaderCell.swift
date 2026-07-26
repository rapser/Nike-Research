import UIKit

final class NikePlusHeaderCell: UITableViewCell {
    static let reuseID = "NikePlusHeaderCell"

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22) ?? .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let memberSinceLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(memberSinceLabel)

        // Un `CGColor` es un valor resuelto: no se reevalúa solo al cambiar de claro a
        // oscuro, a diferencia de un `UIColor` semántico asignado a `textColor` o
        // `tintColor`. Por eso el borde del avatar se vuelve a aplicar a mano cada vez
        // que cambia el modo.
        updateAvatarBorder()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (cell: Self, _) in
            cell.updateAvatarBorder()
        }
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 90),
            avatarImageView.heightAnchor.constraint(equalToConstant: 90),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            memberSinceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            memberSinceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            memberSinceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            memberSinceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
    }

    private func updateAvatarBorder() {
        avatarImageView.layer.borderColor = UIColor.label.cgColor
    }

    func configure(image: UIImage?, name: String, memberSince: String) {
        avatarImageView.image = image
        nameLabel.text = name
        memberSinceLabel.text = memberSince
    }
}
