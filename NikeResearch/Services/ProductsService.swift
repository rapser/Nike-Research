import Foundation

/// Catálogo servido por `GET /products`. El backend devuelve URLs absolutas del CDN de
/// nike.com.pe: las imágenes se descargan en runtime (ver `UIImageView.setRemoteImage`),
/// ya no salen del asset catalog del bundle.
///
/// Misma forma que `CartService`/`FavoritesService`: propiedad cacheada + observers
/// multicast. Antes era el único servicio sin caché, lo que obligaba a `FeedViewModel`
/// a guardar los productos por su cuenta y dejaba a las sugerencias del detalle sin
/// ninguna fuente de datos real.
final class ProductsService {
    static let shared = ProductsService()
    private init() {}

    private(set) var products: [Shoe] = []

    private var updateObservers: [() -> Void] = []
    func onProductsUpdate(_ observer: @escaping () -> Void) {
        updateObservers.append(observer)
    }
    private func notifyUpdated() {
        updateObservers.forEach { $0() }
    }

    func fetchProducts(completion: @escaping (Result<[Shoe], APIError>) -> Void) {
        APIClient.shared.request(.products, decode: [ProductDTO].self) { [weak self] result in
            switch result {
            case .success(let dtos):
                let shoes = dtos.map(Self.toShoe)
                self?.products = shoes
                self?.notifyUpdated()
                completion(.success(shoes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// No hay `clearAll()` a propósito: a diferencia del carrito o los favoritos, el
    /// catálogo no es dato de la cuenta, así que no hay nada que limpiar al cerrar sesión.

    static func toShoe(_ dto: ProductDTO) -> Shoe {
        Shoe(
            uid: dto.id,
            name: dto.name,
            imageURLs: dto.images.compactMap(URL.init(string:)),
            price: dto.price,
            description: dto.description,
            detail: dto.detail
        )
    }
}
