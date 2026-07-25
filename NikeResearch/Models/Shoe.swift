import UIKit

struct Shoe {
    let uid: String
    let name: String
    let images: [UIImage]
    let price: Double
    let description: String
    let detail: String

    var formattedPrice: String { CurrencyFormatter.string(from: price) }
}
