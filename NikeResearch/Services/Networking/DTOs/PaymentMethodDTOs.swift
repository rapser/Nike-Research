import Foundation

struct PaymentMethodDTO: Decodable {
    let id: String
    let holderName: String
    let cardBrand: String
    let cardLast4: String
    let expiryDate: String
    let isDefault: Bool
    let maskedDisplay: String
}

struct CreatePaymentMethodRequestDTO: Encodable {
    let holderName: String
    let cardNumber: String
    let expiryDate: String
    let isDefault: Bool?
}
