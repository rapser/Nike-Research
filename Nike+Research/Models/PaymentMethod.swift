import Foundation

enum CardType {
    case visa, mastercard, amex, discover, other

    /// Backend already classifies the card (`cardBrand`) and never returns the
    /// full number, so this only maps that string — it doesn't sniff digits anymore.
    static func from(brand: String) -> CardType {
        switch brand {
        case "visa": return .visa
        case "mastercard": return .mastercard
        case "amex": return .amex
        case "discover": return .discover
        default: return .other
        }
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
    let cardBrand: String
    let cardLast4: String
    let expiryDate: String

    var cardType: CardType { CardType.from(brand: cardBrand) }
    var lastFour: String { cardLast4 }
    var maskedDisplay: String { "\(cardType.displayName) •••• \(lastFour)" }
    var subtitle: String { "Expires \(expiryDate)  ·  \(holderName)" }

    static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool { lhs.id == rhs.id }
}
