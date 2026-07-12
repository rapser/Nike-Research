import UIKit

final class BuyButtonCell: UITableViewCell {
    static let reuseID = "BuyButtonCell"

    var onBuyTapped: (() -> Void)?
    var onDecrementTapped: (() -> Void)?
    var onIncrementTapped: (() -> Void)?

    private lazy var decrementButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        b.setImage(UIImage(systemName: "minus.circle", withConfiguration: cfg), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        return b
    }()

    private let quantityLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-DemiBold", size: 16) ?? .boldSystemFont(ofSize: 16)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var incrementButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        b.setImage(UIImage(systemName: "plus.circle", withConfiguration: cfg), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        return b
    }()

    private lazy var stepperStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [decrementButton, quantityLabel, incrementButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var buyButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .black
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .boldSystemFont(ofSize: 17)
        b.layer.cornerRadius = 3
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        return b
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(stepperStack)
        contentView.addSubview(buyButton)
        NSLayoutConstraint.activate([
            stepperStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stepperStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            quantityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),

            buyButton.topAnchor.constraint(equalTo: stepperStack.bottomAnchor, constant: 12),
            buyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            buyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            buyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            buyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, quantity: String) {
        buyButton.setTitle(title, for: .normal)
        quantityLabel.text = quantity
    }

    @objc private func decrementTapped() {
        onDecrementTapped?()
    }

    @objc private func incrementTapped() {
        onIncrementTapped?()
    }

    @objc private func buyTapped() {
        onBuyTapped?()
    }
}
