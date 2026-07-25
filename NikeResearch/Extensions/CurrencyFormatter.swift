import Foundation

/// Punto único de formateo de dinero. Antes convivían dos convenciones incompatibles
/// —`"$\(Int(x))"`, que truncaba los centavos, y `String(format: "$%.2f", x)`—, así que
/// un mismo importe podía verse distinto en el detalle, el carrito y el checkout en
/// cuanto un producto tuviera decimales.
enum CurrencyFormatter {
    /// Construir un `NumberFormatter` es caro, así que se reutiliza uno solo. Formatear
    /// con él sí es seguro desde varios hilos.
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    /// Los precios de la API son USD, así que el símbolo va fijo y solo los separadores
    /// siguen a la locale del usuario: en español da "$1.234,50" en vez de "US$ 1,234.50".
    static func string(from value: Double) -> String {
        let amount = formatter.string(from: NSNumber(value: value))
            ?? String(format: "%.2f", value)
        return "$\(amount)"
    }
}
