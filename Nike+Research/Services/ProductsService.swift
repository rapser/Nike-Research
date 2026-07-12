import UIKit

/// Replaces `Shoe.fetchShoes()` with a real `GET /products` call. Images still
/// resolve from the bundled asset catalog (`UIImage(named:)`) — the backend
/// returns the same asset names it was seeded with, not remote URLs.
final class ProductsService {
    static let shared = ProductsService()
    private init() {}

    func fetchProducts(completion: @escaping (Result<[Shoe], APIError>) -> Void) {
        APIClient.shared.request(.products, decode: [ProductDTO].self) { result in
            switch result {
            case .success(let dtos):
                completion(.success(dtos.map(Self.toShoe)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

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
