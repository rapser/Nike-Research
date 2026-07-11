import UIKit

final class BuyButtonCell: UITableViewCell {
    static let reuseID = "BuyButtonCell"

    var onBuyTapped: (() -> Void)?

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
        contentView.addSubview(buyButton)
        NSLayoutConstraint.activate([
            buyButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            buyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            buyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            buyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            buyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) {
        buyButton.setTitle(title, for: .normal)
    }

    @objc private func buyTapped() {
        onBuyTapped?()
    }
}
