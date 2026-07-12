import UIKit

final class FeedViewModel {
    private(set) var shoes: [Shoe] = []
    var onShoeSelected: ((Shoe) -> Void)?

    var title: String { String(localized: "FEED") }
    var shoeCount: Int { shoes.count }

    func loadShoes(completion: @escaping (Error?) -> Void) {
        ProductsService.shared.fetchProducts { [weak self] result in
            switch result {
            case .success(let shoes):
                self?.shoes = shoes
                completion(nil)
            case .failure(let error):
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
