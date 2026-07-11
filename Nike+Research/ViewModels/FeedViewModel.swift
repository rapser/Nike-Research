import UIKit

final class FeedViewModel {
    private(set) var shoes: [Shoe] = []
    var onShoeSelected: ((Shoe) -> Void)?

    var title: String { "FEED" }
    var shoeCount: Int { shoes.count }

    func loadShoes() {
        shoes = Shoe.fetchShoes()
    }

    func selectShoe(at index: Int) {
        guard index < shoes.count else { return }
        onShoeSelected?(shoes[index])
    }

    func shoe(at index: Int) -> Shoe { shoes[index] }
}
