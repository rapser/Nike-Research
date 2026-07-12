import Foundation

extension String {
    /// Luhn checksum — validates that a card number's digits are internally
    /// consistent (catches typos) before it's ever sent anywhere. Doesn't
    /// prove the card is real, just that the number isn't malformed.
    var passesLuhnCheck: Bool {
        let digits = filter(\.isNumber).compactMap(\.wholeNumberValue)
        guard digits.count >= 12 else { return false }

        var sum = 0
        for (index, digit) in digits.reversed().enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
}
