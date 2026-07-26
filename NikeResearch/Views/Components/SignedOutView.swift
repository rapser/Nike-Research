import UIKit

/// Mensaje para pantallas que solo tienen sentido con sesión iniciada. Se usa como
/// `backgroundView` de la tabla, alternándose con `LoadingOverlayView`: nunca coinciden,
/// porque sin sesión no se llega a cargar nada.
final class SignedOutView: UIView {
    private let iconView: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 48, weight: .ultraLight)
        iv.image = UIImage(systemName: "person.crop.circle", withConfiguration: cfg)
        iv.tintColor = .quaternaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 20) ?? .boldSystemFont(ofSize: 20)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }

    /// Como se usa de `backgroundView`, la tabla la posiciona por frame.
    func useAsBackground(of tableView: UITableView) {
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundView = self
    }
}
