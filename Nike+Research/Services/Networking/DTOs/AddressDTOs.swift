import Foundation

struct AddressDTO: Decodable {
    let id: String
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let latitude: Double
    let longitude: Double
    let isDefault: Bool
}

struct CreateAddressRequestDTO: Encodable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let latitude: Double
    let longitude: Double
    let isDefault: Bool?
}
