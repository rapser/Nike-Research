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
- **Ambientes QA/Producción**: dos schemes de Xcode (`Nike+Research-QA` → Debug → `localhost:3000`, `Nike+Research` → Release → `https://nike-store-api.onrender.com`), URL inyectada vía `.xcconfig` + `Info.plist`, sin tocar código para cambiar de ambiente.
- Timeout de red subido a 90s (antes 60s, default de Alamofire) para tolerar el cold start del plan Free de Render.

### Fixed

- **Botón "+ ADD NEW CARD" en Select Card no navegaba**: `SelectCardViewController.viewDidLoad` sobreescribía `SelectCardViewModel.onAddNewCard` (closure de una sola propiedad) después de que el Coordinator ya lo había asignado para navegar — se quitó la reasignación muerta en el ViewController.
- **Badge del carrito no se actualizaba** en varios flujos (login, logout, agregar producto) — se unificó el patrón de notificación multicast y se conectó `AppCoordinator`/`ProfileCoordinator` a los eventos correctos.
- **Favoritos no persistían** tras cerrar el app — migrado a la API real (antes vivía solo en memoria).
- **Parseo de fechas ISO8601 con fracciones de segundo** fallaba silenciosamente (fecha de pedidos y "member since" quedaban mal) — nuevo helper `Date.fromAPI(_:)` con `.withFractionalSeconds`.
- **Pedido duplicado en el historial**: `CartCoordinator` llamaba `OrdersService.shared.save(order)` después de que `checkout()` ya lo había insertado — se quitó la llamada redundante.
- **Crash potencial al ver un pedido con una tarjeta ya eliminada**: `OrdersService.toOrder` usaba `fatalError` si el método de pago era `nil`; ahora muestra un placeholder "Card removed".
- `node_modules` estaba commiteado en el historial de git — removido y agregado `.gitignore` correcto.

### Changed

- `PaymentMethod`: de `cardNumber: String` a `cardBrand` + `cardLast4` (el backend nunca devuelve el número completo).
- `CartItem`: agregado `id: String` (id del servidor, necesario para `PATCH`/`DELETE /cart/items/:id`).
- Deployment target mínimo subido a iOS 18 (para usar `Synchronization.Mutex`).

### Not included (deferred)

- Loading state en: swipe-to-delete de tarjetas/direcciones, stepper de cantidad del carrito, "Clear Cart" (identificado, no implementado a pedido explícito del usuario).
- Gateway de pago real (hoy `MockPaymentGateway` del lado del backend).
