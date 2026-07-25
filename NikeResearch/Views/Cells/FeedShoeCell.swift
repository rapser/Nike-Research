import UIKit

final class FeedShoeCell: UITableViewCell {
    static let reuseID = "FeedShoeCell"

    private let shoeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-Medium", size: 17) ?? .systemFont(ofSize: 17)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .darkGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupHierarchy()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupHierarchy() {
        contentView.addSubview(shoeImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            shoeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shoeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shoeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shoeImageView.widthAnchor.constraint(equalTo: shoeImageView.heightAnchor),

            nameLabel.topAnchor.constraint(equalTo: shoeImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(image: UIImage?, name: String, price: String) {
        shoeImageView.image = image
        nameLabel.text = name
        priceLabel.text = price
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        shoeImageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
    }
}
