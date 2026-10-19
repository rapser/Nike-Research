import Foundation

/// Punto único de formateo de dinero. Antes convivían dos convenciones incompatibles
/// —`"$\(Int(x))"`, que truncaba los centavos, y `String(format: "$%.2f", x)`—, así que
/// un mismo importe podía verse distinto en el detalle, el carrito y el checkout en
/// cuanto un producto tuviera decimales.
enum CurrencyFormatter {
    /// Construir un `NumberFormatter` es caro, así que se reutiliza uno solo. Formatear
    /// con él sí es seguro desde varios hilos.
    ///
    /// La locale va fija en `es_PE` y no sigue la del dispositivo: la tienda es peruana
    /// y los precios de la API son soles, así que un usuario con el iPhone en inglés o
    /// en español de España debe ver igual "S/ 1,234.50" —separador de miles coma y
    /// decimal punto—, no "S/ 1.234,50".
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "es_PE")
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    /// Los precios de la API son soles (PEN), así que el símbolo va fijo.
    static func string(from value: Double) -> String {
        let amount = formatter.string(from: NSNumber(value: value))
            ?? String(format: "%.2f", value)
        return "S/ \(amount)"
    }
}
