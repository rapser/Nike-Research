import Foundation

struct CartItemDTO: Decodable {
    let id: String
    let product: ProductDTO
    let quantity: Int
    let lineTotal: Double
}

struct CartDTO: Decodable {
    let items: [CartItemDTO]
    let subtotal: Double
    let tax: Double
    let shipping: Double
    let total: Double
}

struct AddCartItemRequestDTO: Encodable {
    let productId: String
    let quantity: Int
}

struct UpdateCartItemRequestDTO: Encodable {
    let quantity: Int
}
