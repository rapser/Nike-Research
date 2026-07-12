import Foundation

struct OrderItemDTO: Decodable {
    let productId: String
    let shoeName: String
    let shoePrice: Double
    let quantity: Int
}

struct OrderDTO: Decodable {
    let id: String
    let number: String
    let items: [OrderItemDTO]
    let subtotal: Double
    let tax: Double
    let shipping: Double
    let total: Double
    let status: String
    let paymentMethod: PaymentMethodDTO?
    let placedAt: String
}

struct CreateOrderRequestDTO: Encodable {
    let paymentMethodId: String
}
