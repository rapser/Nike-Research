import Foundation

struct Shoe {
    let uid: String
    let name: String
    /// URLs del CDN de nike.com.pe (6 vistas por producto). Se descargan en runtime —
    /// el catálogo ya no depende de imágenes empaquetadas en el bundle.
    let imageURLs: [URL]
    let price: Double
    let description: String
    let detail: String

    var formattedPrice: String { CurrencyFormatter.string(from: price) }
}
