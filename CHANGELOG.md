# Changelog

## [Unreleased]

Migración completa del app de datos dummy en memoria a la API real (`nike-store-api`), más mejoras de UX y localización completa.

### Added

- **Capa de networking** (`Services/Networking/`): `APIClient` (Alamofire, dos `Session` — autenticada/pública), `APIEndpoint`, `APIError` (decodifica el envelope de error del backend), `AuthTokenInterceptor` (Bearer token + refresh automático single-flight vía `Mutex<State>` de `Synchronization`, sin `@unchecked Sendable`), `KeychainTokenStore`, `APILogger` (loguea cada request/response con método, URL, status, headers y JSON pretty-printed en consola), DTOs `Codable` por dominio.
- **Auth real**: `RemoteAuthRepository` reemplaza `DummyAuthRepository` como default de `AuthService`; login/registro/logout/refresh contra la API, tokens persistidos en Keychain.
- **Servicios migrados a la API real** (antes en memoria, ahora persistidos server-side y recuperables tras logout/reinstalación): `ProductsService` (nuevo), `CartService`, `FavoritesService`, `AddressService`, `PaymentMethodsService`, `OrdersService`, `NikePlusService`. Todos usan el mismo patrón: propiedad cacheada + multicast observer (`onXUpdate`, reemplaza el patrón de closure único que causaba que un suscriptor pisara al otro).
- **Edición de direcciones** (`PATCH /addresses/:id`) — antes solo se podían agregar/eliminar.
- **UX de tarjetas**: validación de número con algoritmo de Luhn, se enmascara a `**** 1234` tras completarse, selectores nativos (`UIPickerView`) de mes/año en dos campos separados.
- **UX de carrito**: stepper de cantidad +/-, ícono de basura para eliminar un ítem individual, badge del tab con el conteo actualizado en cada mutación y al iniciar sesión/lanzar el app.
- **Loader en el botón "BUY"** del detalle de producto mientras se agrega al carrito (spinner + botón deshabilitado durante la llamada).
- **Localización completa es/en** (`Localizable.xcstrings`) — toda la UI (Auth, Feed, ShoeDetail, Cart, Checkout, Favorites, NikePlus, Profile, Direcciones, Tarjetas, Pedidos, alerts de los Coordinators).
- **Ambientes QA/Producción**: dos schemes de Xcode (`NikeResearch-QA` → Debug → `localhost:3000`, `NikeResearch` → Release → `https://nike-store-api.onrender.com`), URL inyectada vía `.xcconfig` + `Info.plist`, sin tocar código para cambiar de ambiente.
- Timeout de red subido a 90s (antes 60s, default de Alamofire) para tolerar el cold start del plan Free de Render.
- **Estado de carga explícito** (`LoadState` + `LoadingOverlayView`) en las 8 pantallas que consultan la API. Antes solo 1 de 8 tenía indicador; el resto dejaba la pantalla quieta hasta que llegaba la respuesta, que con el cold start de Render puede tardar hasta 90s.
- **`CurrencyFormatter`**: punto único de formateo de dinero, con `NumberFormatter` reutilizado y separadores de la locale del dispositivo.
- **Ciclo de vida de `UIScene`**: nuevo `SceneDelegate` como dueño de la ventana y del `AppCoordinator`, más `UIApplicationSceneManifest` en el `Info.plist`. Xcode ya avisaba de que la falta de adopción pasará a ser un assert.
- **Preparación de la primera build para App Store**: `ITSAppUsesNonExemptEncryption = false` (la app solo usa Keychain y HTTPS, criptografía exenta), para no responder el cuestionario de exportación en cada envío.

### Fixed

- **Botón "+ ADD NEW CARD" en Select Card no navegaba**: `SelectCardViewController.viewDidLoad` sobreescribía `SelectCardViewModel.onAddNewCard` (closure de una sola propiedad) después de que el Coordinator ya lo había asignado para navegar — se quitó la reasignación muerta en el ViewController.
- **Badge del carrito no se actualizaba** en varios flujos (login, logout, agregar producto) — se unificó el patrón de notificación multicast y se conectó `AppCoordinator`/`ProfileCoordinator` a los eventos correctos.
- **Favoritos no persistían** tras cerrar el app — migrado a la API real (antes vivía solo en memoria).
- **Parseo de fechas ISO8601 con fracciones de segundo** fallaba silenciosamente (fecha de pedidos y "member since" quedaban mal) — nuevo helper `Date.fromAPI(_:)` con `.withFractionalSeconds`.
- **Pedido duplicado en el historial**: `CartCoordinator` llamaba `OrdersService.shared.save(order)` después de que `checkout()` ya lo había insertado — se quitó la llamada redundante.
- **Crash potencial al ver un pedido con una tarjeta ya eliminada**: `OrdersService.toOrder` usaba `fatalError` si el método de pago era `nil`; ahora muestra un placeholder "Card removed".
- `node_modules` estaba commiteado en el historial de git — removido y agregado `.gitignore` correcto.
- **Las sugerencias del detalle de producto servían un catálogo hardcodeado**: `ShoeDetailViewModel.suggestions` devolvía `Shoe.fetchShoes()`, un array literal de 2017 con sus propios uids y precios, que nunca consultaba la API. Era el único ViewModel que se saltaba la capa de Service. Ahora salen de `ProductsService`, excluyendo el producto que se está viendo, y se cachean en vez de reconstruirse en cada acceso (los tres accesores se llaman una vez por celda durante el scroll, y cada uno decodificaba hasta 8 `UIImage` del asset catalog). `Shoe.fetchShoes()` fue eliminado.
- **El empty state aparecía durante la carga**: las 4 pantallas que lo tenían leían la caché del servicio, que arranca en `[]`, así que mostraban "no tienes favoritos" mientras la petición seguía en vuelo — hasta minuto y medio en un cold start — y luego un alert de error de golpe. `LoadState` distingue "todavía no sé" de "sé que está vacío". `CartViewController` decidía sus filas con `isEmpty` y tenía el mismo problema.
- **Dos convenciones de formato de moneda incompatibles**: 4 sitios truncaban los centavos con `Int()` y 6 usaban `%.2f`, incluso dentro del mismo archivo (`Order.swift`). No llegó a afectar a usuarios porque todos los precios del seed son enteros, pero se activaba con el primer producto con decimales. Unificado en `CurrencyFormatter`.
- **Version y Build no llegaban al archive**: el `.ipa` salía siempre como `1.0 (1)` sin importar lo que se pusiera en Xcode. El `Info.plist` tenía `CFBundleShortVersionString` y `CFBundleVersion` como literales, así que `MARKETING_VERSION` y `CURRENT_PROJECT_VERSION` no los leía nadie; ahora apuntan a `$(MARKETING_VERSION)` y `$(CURRENT_PROJECT_VERSION)`.
- **App Store Connect rechazaba la subida**: `CFBundleExecutable` resolvía a `Nike+Research` vía `PRODUCT_NAME = $(TARGET_NAME)`, y `+` no es un carácter permitido en esa clave. El proyecto, la carpeta y los schemes pasaron a llamarse `NikeResearch`.

### Changed

- `PaymentMethod`: de `cardNumber: String` a `cardBrand` + `cardLast4` (el backend nunca devuelve el número completo).
- `CartItem`: agregado `id: String` (id del servidor, necesario para `PATCH`/`DELETE /cart/items/:id`).
- Deployment target mínimo subido a iOS 18 (para usar `Synchronization.Mutex`).
- **Los precios se muestran con centavos** (`$180` → `$180.00`) en feed, favoritos, detalle, carrito y detalle de pedido, que es lo que el checkout ya hacía.
- **`ProductsService` pasa a ser la fuente de verdad del catálogo**: era el único de los 8 servicios sin propiedad cacheada ni multicast observer, lo que obligaba a `FeedViewModel` a ser el único ViewModel que guardaba estado propio. No lleva `clearAll()` a propósito: el catálogo no es dato de cuenta y no hay nada que limpiar al cerrar sesión.
- `AppDelegate` conserva solo la configuración del proceso (apariencia global y red); la ventana y el `AppCoordinator` viven ahora en `SceneDelegate`.
- `UIRequiredDeviceCapabilities`: de `armv7` (legado de 32 bits) a `arm64`, coherente con el deployment target de iOS 18.

### Not included (deferred)

- Loading state en: swipe-to-delete de tarjetas/direcciones, stepper de cantidad del carrito, "Clear Cart" (identificado, no implementado a pedido explícito del usuario). El estado de carga añadido cubre la carga inicial de cada pantalla, no estas mutaciones puntuales.
- Empty state en las 4 pantallas que no lo tienen (`MyCards`, `SelectCard`, `NikePlus`, `Feed`) — requiere diseño y claves nuevas de localización.
- Sin target de tests: el proyecto no tiene ninguno. La lógica pura (Luhn, parseo ISO8601, el refresh single-flight del interceptor) sigue sin cobertura.
- Accesibilidad: no hay `accessibilityLabel`/`accessibilityIdentifier` en ninguna pantalla, y las fuentes usan tamaño fijo (`systemFont(ofSize:)`), sin soporte de Dynamic Type.
- Gateway de pago real (hoy `MockPaymentGateway` del lado del backend).
