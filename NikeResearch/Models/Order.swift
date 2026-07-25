import Foundation

struct OrderItem {
    let shoeName: String
    let shoePrice: Double
    let quantity: Int

    var formattedPrice: String { "$\(Int(shoePrice))" }
    var formattedLineTotal: String { String(format: "$%.2f", shoePrice * Double(quantity)) }
}

struct Order {
    let id: String
    let number: String
    let items: [OrderItem]
    let subtotal: Double
    let tax: Double
    let shipping: Double
    let total: Double
    let paymentMethod: PaymentMethod
    let placedAt: Date

    var formattedTotal: String { String(format: "$%.2f", total) }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: placedAt)
    }

    var estimatedDelivery: String {
        let cal = Calendar.current
        let low = cal.date(byAdding: .day, value: 3, to: placedAt)!
        let high = cal.date(byAdding: .day, value: 5, to: placedAt)!
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: low)) – \(f.string(from: high))"
    }
}
