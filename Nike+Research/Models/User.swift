import Foundation

struct User: Codable, Equatable {
    let id: String
    var name: String
    var email: String
    var memberSince: String
}
