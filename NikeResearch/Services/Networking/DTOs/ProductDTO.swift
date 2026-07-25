import Foundation

struct ProductDTO: Decodable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let detail: String
    let images: [String]
}
