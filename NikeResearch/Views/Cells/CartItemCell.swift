import UIKit

final class CartItemCell: UITableViewCell {
    static let reuseID = "CartItemCell"

    var onDecrementTapped: (() -> Void)?
    var onIncrementTapped: (() -> Void)?
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

    private lazy var decrementButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        b.setImage(UIImage(systemName: "minus.circle", withConfiguration: cfg), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        return b
    }()

    private let quantityValueLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-DemiBold", size: 14) ?? .boldSystemFont(ofSize: 14)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var incrementButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        b.setImage(UIImage(systemName: "plus.circle", withConfiguration: cfg), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        return b
    }()

    private lazy var stepperStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [decrementButton, quantityValueLabel, incrementButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var trashButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        b.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        b.tintColor = .black
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
        contentView.addSubview(stepperStack)
        contentView.addSubview(trashButton)

        NSLayoutConstraint.activate([
            shoeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            shoeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            shoeImageView.widthAnchor.constraint(equalToConstant: 96),
            shoeImageView.heightAnchor.constraint(equalToConstant: 96),
            shoeImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24),

            trashButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            trashButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            trashButton.widthAnchor.constraint(equalToConstant: 24),
            trashButton.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: shoeImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trashButton.leadingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            stepperStack.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            stepperStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            stepperStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            quantityValueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 18)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(image: UIImage?, name: String, price: String, quantity: Int) {
        shoeImageView.image = image
        nameLabel.text = name
        priceLabel.text = price
        quantityValueLabel.text = "\(quantity)"
    }

    @objc private func decrementTapped() {
        onDecrementTapped?()
    }

    @objc private func incrementTapped() {
        onIncrementTapped?()
    }

    @objc private func removeTapped() {
        onRemoveTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        shoeImageView.image = nil
        onDecrementTapped = nil
        onIncrementTapped = nil
        onRemoveTapped = nil
    }
}
