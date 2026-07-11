import UIKit

final class CartItemCell: UITableViewCell {
    static let reuseID = "CartItemCell"

    var onRemoveTapped: (() -> Void)?

    private let shoeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-Medium", size: 15) ?? .boldSystemFont(ofSize: 15)
        l.numberOfLines = 2
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

    private let quantityLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 12) ?? .systemFont(ofSize: 12)
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var removeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("REMOVE", for: .normal)
        b.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 12) ?? .systemFont(ofSize: 12)
        b.setTitleColor(.black, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        return b
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(shoeImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(removeButton)

        NSLayoutConstraint.activate([
            shoeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            shoeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            shoeImageView.widthAnchor.constraint(equalToConstant: 96),
            shoeImageView.heightAnchor.constraint(equalToConstant: 96),
            shoeImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: shoeImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            quantityLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            removeButton.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 8),
            removeButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            removeButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(image: UIImage?, name: String, price: String, quantity: Int) {
        shoeImageView.image = image
        nameLabel.text = name
        priceLabel.text = price
        quantityLabel.text = "Qty: \(quantity)"
    }

    @objc private func removeTapped() {
        onRemoveTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        shoeImageView.image = nil
        onRemoveTapped = nil
    }
}
