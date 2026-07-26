import UIKit

/// Spinner centrado que las pantallas muestran mientras esperan a la API.
///
/// Existía uno idéntico embebido en `FeedViewController`; se extrajo aquí porque las
/// otras 7 pantallas que hacen fetch no tenían ninguno y no tenía sentido copiarlo
/// siete veces.
final class LoadingOverlayView: UIView {
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        // `.label` y no `.black`: en modo oscuro un spinner negro sobre fondo oscuro
        // era invisible, que es justo el momento en que hace falta verlo.
        indicator.color = .label
        return indicator
    }()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        isHidden = true
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    /// Se ancla a los bordes de `parent` y se pone por encima del resto del contenido.
    func pin(to parent: UIView) {
        parent.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.topAnchor),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }

    /// Alternativa a `pin(to:)` para las pantallas que son `UITableViewController`: ahí
    /// `view` *es* la table view, así que un overlay anclado a ella se desplazaría con
    /// el scroll. Como `backgroundView` queda fijo y visible mientras no hay filas, que
    /// es justo el caso de la carga inicial.
    func useAsBackground(of tableView: UITableView) {
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundView = self
    }

    var isLoading: Bool = false {
        didSet {
            isHidden = !isLoading
            isLoading ? indicator.startAnimating() : indicator.stopAnimating()
        }
    }
}
