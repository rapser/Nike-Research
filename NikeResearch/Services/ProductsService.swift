import UIKit

/// Catálogo servido por `GET /products`. Las imágenes siguen resolviéndose del asset
/// catalog del bundle (`UIImage(named:)`) — el backend devuelve los mismos nombres de
/// asset con los que fue sembrado, no URLs remotas.
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
            images: dto.images.compactMap { UIImage(named: $0) },
            price: dto.price,
            description: dto.description,
            detail: dto.detail
        )
    }
}
