import Kingfisher
import UIKit

/// Punto único de carga de imágenes remotas. El catálogo ya no vive en el asset
/// catalog: `GET /products` devuelve URLs del CDN de nike.com.pe, así que cada celda
/// descarga su imagen al configurarse.
///
/// Kingfisher se encarga de la caché (memoria + disco) y de cancelar la descarga
/// cuando la celda se recicla; sin esa cancelación, al scrollear rápido la imagen de
/// una celda anterior puede llegar tarde y pintarse sobre la celda ya reutilizada.
extension UIImageView {
    /// Pasa `nil` para limpiar la vista (p. ej. desde `prepareForReuse`).
    func setRemoteImage(_ url: URL?) {
        guard let url else {
            kf.cancelDownloadTask()
            image = nil
            return
        }
        kf.setImage(
            with: url,
            // El fade aplica también a la imagen que ya estaba en caché, para que la
            // celda no cambie de aspecto según si la foto venía del disco o de la red.
            options: [.transition(.fade(0.2)), .forceTransition]
        )
    }
}
