import UIKit

/// Row used by Login/Register to switch between the two flows, e.g. "Don't have an account? SIGN UP".
final class AuthLinkCell: UITableViewCell {
    static let reuseID = "AuthLinkCell"

    private let promptLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let actionLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 13) ?? .boldSystemFont(ofSize: 13)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let stack = UIStackView(arrangedSubviews: [promptLabel, actionLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(prompt: String, actionTitle: String) {
        promptLabel.text = prompt
        actionLabel.text = actionTitle
    }
}
