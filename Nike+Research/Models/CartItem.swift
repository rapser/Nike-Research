struct CartItem {
    let id: String
    let shoe: Shoe
    var quantity: Int

    var lineTotal: Double { shoe.price * Double(quantity) }
    var formattedLineTotal: String { "$\(Int(lineTotal))" }
}
