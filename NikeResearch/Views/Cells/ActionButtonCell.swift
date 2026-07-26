import UIKit

final class ActionButtonCell: UITableViewCell {
    static let reuseID = "ActionButtonCell"

    enum Style {
        case primary
        case outline
    }

    var onActionTapped: (() -> Void)?

    /// Último estilo aplicado, para poder repintar el borde cuando cambia el modo
    /// claro/oscuro sin esperar a que la celda se reconfigure.
    private var appliedStyle: Style = .primary
    private var appliedEnabled = true

    private lazy var actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .label
        b.setTitleColor(.systemBackground, for: .normal)
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
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (cell: Self, _) in
            cell.applyStyle()
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, enabled: Bool = true, style: Style = .primary) {
        actionButton.setTitle(title, for: .normal)
        actionButton.isUserInteractionEnabled = enabled
        appliedStyle = style
        appliedEnabled = enabled
        applyStyle()
    }

    /// El botón primario es el elemento de mayor contraste con el fondo, así que se
    /// invierte con el tema: negro sobre blanco en claro, blanco sobre negro en oscuro.
    /// Dejarlo negro fijo lo haría desaparecer sobre el fondo oscuro.
    private func applyStyle() {
        switch appliedStyle {
        case .primary:
            actionButton.backgroundColor = appliedEnabled ? .label : .tertiaryLabel
            actionButton.setTitleColor(.systemBackground, for: .normal)
            actionButton.layer.borderWidth = 0
        case .outline:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitleColor(appliedEnabled ? .label : .tertiaryLabel, for: .normal)
            actionButton.layer.borderWidth = 1
            // `borderColor` es un `CGColor` ya resuelto: no se reevalúa solo al cambiar
            // de modo, por eso se repinta desde `registerForTraitChanges`.
            actionButton.layer.borderColor = (appliedEnabled ? UIColor.label : UIColor.tertiaryLabel).cgColor
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
