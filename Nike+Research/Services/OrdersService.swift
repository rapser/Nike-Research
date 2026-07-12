import Foundation

final class OrdersService {
    static let shared = OrdersService()
    private init() {}

    private(set) var orders: [Order] = []
    var onOrdersUpdated: (() -> Void)?

    /// `GET /orders` — order history. The server already returns full detail
    /// (items, payment method, totals) per order, so `OrderDetailViewModel` just
    /// reuses the object from this list instead of making a second `/orders/:id`
    /// call when the user taps into one.
    func fetchOrders(completion: @escaping (Error?) -> Void) {
        APIClient.shared.request(.orders, decode: [OrderDTO].self) { [weak self] result in
            switch result {
            case .success(let dtos):
                self?.orders = dtos.map(Self.toOrder)
                self?.onOrdersUpdated?()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    /// `POST /orders` — checks out whatever is in the server-side cart against the
    /// given payment method. The server computes totals, order number, and runs the
    /// mock payment gateway; a `422 PAYMENT_DECLINED` surfaces through `completion`
    /// like any other `APIError` (e.g. a test card ending in `0002`).
    func checkout(paymentMethodId: String, completion: @escaping (Result<Order, APIError>) -> Void) {
        let body = CreateOrderRequestDTO(paymentMethodId: paymentMethodId)
        APIClient.shared.request(.createOrder, body: body, decode: OrderDTO.self) { [weak self] result in
            switch result {
            case .success(let dto):
                let order = Self.toOrder(dto)
                self?.orders.insert(order, at: 0)
                self?.onOrdersUpdated?()
                completion(.success(order))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Local-only reset, no network call — used on logout.
    func clearAll() {
        orders = []
        onOrdersUpdated?()
    }

    private static func toOrder(_ dto: OrderDTO) -> Order {
        // The order's payment method can end up null server-side if the card used
        // was later deleted (the FK is ON DELETE SET NULL) — fall back to a
        // placeholder instead of crashing on what's now a reachable path.
        let paymentMethod: PaymentMethod
        if let pm = dto.paymentMethod {
            paymentMethod = PaymentMethod(id: pm.id, holderName: pm.holderName, cardBrand: pm.cardBrand, cardLast4: pm.cardLast4, expiryDate: pm.expiryDate)
        } else {
            paymentMethod = PaymentMethod(id: "", holderName: "Card removed", cardBrand: "other", cardLast4: "----", expiryDate: "—")
        }
        let items = dto.items.map { OrderItem(shoeName: $0.shoeName, shoePrice: $0.shoePrice, quantity: $0.quantity) }
        let placedAt = Date.fromAPI(dto.placedAt) ?? Date()

        return Order(
            id: dto.id,
            number: dto.number,
            items: items,
            subtotal: dto.subtotal,
            tax: dto.tax,
            shipping: dto.shipping,
            total: dto.total,
            paymentMethod: paymentMethod,
            placedAt: placedAt
        )
    }
}
