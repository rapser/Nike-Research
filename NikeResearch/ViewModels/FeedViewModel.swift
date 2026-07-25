import UIKit

final class FeedViewModel {
    var onShoeSelected: ((Shoe) -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    /// El catálogo vive en `ProductsService`, no aquí: era el único ViewModel que
    /// guardaba su propia copia. Suscribirse es seguro porque el Feed es raíz de tab y
    /// se instancia una sola vez, a diferencia del detalle de producto.
    init() {
        ProductsService.shared.onProductsUpdate { [weak self] in
            self?.onStateChanged?()
        }
    }

    var shoes: [Shoe] { ProductsService.shared.products }

    var title: String { String(localized: "FEED") }
    var shoeCount: Int { shoes.count }

    func loadShoes(completion: @escaping (Error?) -> Void) {
        state = .loading
        ProductsService.shared.fetchProducts { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let shoes):
                self.state = shoes.isEmpty ? .empty : .loaded
                completion(nil)
            case .failure(let error):
                self.state = .failed
                completion(error)
            }
        }
    }

    func selectShoe(at index: Int) {
        guard index < shoes.count else { return }
        onShoeSelected?(shoes[index])
    }

    func shoe(at index: Int) -> Shoe { shoes[index] }
}
