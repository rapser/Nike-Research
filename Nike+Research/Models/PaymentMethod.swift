import Foundation

enum CardType {
    case visa, mastercard, amex, discover, other

    static func detect(from number: String) -> CardType {
        let n = number.filter { $0.isNumber }
        if n.hasPrefix("4") { return .visa }
        if n.hasPrefix("5") || n.hasPrefix("2") { return .mastercard }
        if n.hasPrefix("34") || n.hasPrefix("37") { return .amex }
        if n.hasPrefix("6") { return .discover }
        return .other
    }

    var displayName: String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "Mastercard"
        case .amex: return "Amex"
        case .discover: return "Discover"
        case .other: return "Card"
        }
    }
}

struct PaymentMethod: Equatable {
    let id: String
    let holderName: String
    let cardNumber: String
    let expiryDate: String

    var cardType: CardType { CardType.detect(from: cardNumber) }
    var lastFour: String { String(cardNumber.filter { $0.isNumber }.suffix(4)) }
    var maskedDisplay: String { "\(cardType.displayName) •••• \(lastFour)" }
    var subtitle: String { "Expires \(expiryDate)  ·  \(holderName)" }

    static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool { lhs.id == rhs.id }
}
