import Foundation

// Mirrors nike-store-api's auth DTOs (see CONTRACT.md / openapi.json).

struct RegisterRequestDTO: Encodable {
    let name: String
    let email: String
    let password: String
}

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct RefreshRequestDTO: Encodable {
    let refreshToken: String
}

struct UserProfileDTO: Decodable {
    let id: String
    let name: String
    let email: String
    let memberSince: String
}

struct AuthResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: UserProfileDTO
}
