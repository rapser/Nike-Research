import UIKit

final class ActionButtonCell: UITableViewCell {
    static let reuseID = "ActionButtonCell"

    enum Style {
        case primary
        case outline
    }

    var onActionTapped: (() -> Void)?

    private lazy var actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .black
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .boldSystemFont(ofSize: 17)
        b.layer.cornerRadius = 3
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return b
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, enabled: Bool = true, style: Style = .primary) {
        actionButton.setTitle(title, for: .normal)
        actionButton.isUserInteractionEnabled = enabled
        switch style {
        case .primary:
            actionButton.backgroundColor = enabled ? .black : UIColor.black.withAlphaComponent(0.3)
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.layer.borderWidth = 0
        case .outline:
            actionButton.backgroundColor = .white
            actionButton.setTitleColor(enabled ? .black : UIColor.black.withAlphaComponent(0.3), for: .normal)
            actionButton.layer.borderWidth = 1
            actionButton.layer.borderColor = (enabled ? UIColor.black : UIColor.black.withAlphaComponent(0.3)).cgColor
        }
    }

    @objc private func actionTapped() {
        onActionTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onActionTapped = nil
    }
}
