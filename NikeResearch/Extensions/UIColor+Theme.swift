import UIKit

extension UIColor {
    /// Lienzo sobre el que se muestran las fotos de producto. Es blanco en ambos modos
    /// **a propósito**: los JPEG del catálogo tienen el fondo blanco opaco, así que un
    /// contenedor que siguiera el tema dibujaría en oscuro un recuadro blanco flotando
    /// alrededor del zapato. Es el mismo criterio que usan las tiendas online: la ficha
    /// de producto conserva su lienzo, el resto de la interfaz sí sigue el tema.
    static let productCanvas = UIColor.white

    /// Para lo que se dibuja *encima* de `productCanvas` (los puntos del carrusel), que
    /// por lo mismo tampoco puede seguir el tema.
    static let onProductCanvas = UIColor.black
}
