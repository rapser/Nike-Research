import UIKit

struct Shoe {
    let uid: String
    let name: String
    let images: [UIImage]
    let price: Double
    let description: String
    let detail: String

    var formattedPrice: String { "$\(Int(price))" }

    static func fetchShoes() -> [Shoe] {
        var shoes = [Shoe]()

        let shoe1 = Shoe(
            uid: "875942-100",
            name: "NIKE AIR MAX 1 ULTRA 2.0 FLYKNIT",
            images: (1...8).compactMap { UIImage(named: "s\($0)") },
            price: 180,
            description: "LIGHTER THAN EVER! The Nike Air Max 1 Ultra 2.0 Flyknit Men's Shoe updates the iconic original with an ultra-lightweight upper while keeping the plush, time-tested Max Air cushioning.",
            detail: "LIGHTER THAN EVER! The Nike Air Max 1 Ultra 2.0 Flyknit Men's Shoe updates the iconic original with an ultra-lightweight upper while keeping the plush, time-tested Max Air cushioning."
        )
        shoes.append(shoe1)

        let shoe2 = Shoe(
            uid: "880843-003",
            name: "NIKE FREE RN FLYKNIT 2017",
            images: (1...7).compactMap { UIImage(named: "t\($0)") },
            price: 120,
            description: "The Nike Free RN Flyknit 2017 Men's Running Shoe brings you miles of comfort with an exceptionally flexible outsole for the ultimate natural ride.",
            detail: "The Nike Free RN Flyknit 2017 Men's Running Shoe brings you miles of comfort with an exceptionally flexible outsole for the ultimate natural ride. Flyknit fabric wraps your foot for a snug, supportive fit while a tri-star outsole expands and flexes to let your foot move naturally."
        )
        shoes.append(shoe2)

        let shoe3 = Shoe(
            uid: "384664-113",
            name: "AIR JORDAN 6 RETRO",
            images: (1...6).compactMap { UIImage(named: "j\($0)") },
            price: 190,
            description: "The Air Jordan 6 Retro Men's Shoe celebrates a championship heritage with design lines and plush cushioning inspired by the ground-breaking hoops original.",
            detail: "The Air Jordan 6 Retro Men's Shoe celebrates a championship heritage with design lines and plush cushioning inspired by the ground-breaking hoops original."
        )
        shoes.append(shoe3)

        let shoe4 = Shoe(
            uid: "805144-852",
            name: "TECH FLEECE WINDRUNNER",
            images: (1...6).compactMap { UIImage(named: "f\($0)") },
            price: 130,
            description: "The Nike Sportswear Tech Fleece Windrunner Men's Hoodie is redesigned for cooler weather with smooth, engineered fleece that offers lightweight warmth.",
            detail: "The Nike Sportswear Tech Fleece Windrunner Men's Hoodie is redesigned for cooler weather with smooth, engineered fleece that offers lightweight warmth. Bonded seams lend a modern update to the classic chevron design."
        )
        shoes.append(shoe4)

        return shoes
    }
}
