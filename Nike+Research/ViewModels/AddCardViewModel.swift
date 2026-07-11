import Foundation

final class AddCardViewModel {
    var holderName: String = ""
    var cardNumber: String = ""
    var expiryDate: String = ""
    var cvv: String = ""
    var onCardSaved: (() -> Void)?

    var title: String { "ADD CARD" }

    var isValid: Bool {
        !holderName.isEmpty &&
        cardNumber.filter({ $0.isNumber }).count >= 16 &&
        expiryDate.count == 5 &&
        cvv.count >= 3
    }

    func saveCard() {
        let card = PaymentMethod(
            id: UUID().uuidString,
            holderName: holderName,
            cardNumber: cardNumber,
            expiryDate: expiryDate
        )
        PaymentMethodsService.shared.add(card)
        onCardSaved?()
    }
}
