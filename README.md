# NikeResearch

App iOS de e-commerce estilo Nike (catálogo, carrito, checkout, favoritos, direcciones, tarjetas, historial de pedidos, Nike+) escrita en UIKit con arquitectura MVVM + Coordinators. Consume la API real [`nike-store-api`](https://github.com/rapser/nike-store-api) (NestJS + Prisma + PostgreSQL en Neon), desplegada en Render.

## Stack

- Swift 6, UIKit (sin SwiftUI), iOS 18+
- MVVM + Coordinators — sin framework de DI, los ViewModels/Coordinators llaman a servicios singleton (`XService.shared`)
- [Alamofire](https://github.com/Alamofire/Alamofire) para networking, con completion handlers (sin async/await ni Combine, para no mezclar paradigmas de concurrencia en el mismo código)
- `Synchronization.Mutex` (Swift 6) para estado concurrente real (`Sendable` sin `@unchecked`)
- `Localizable.xcstrings` (String Catalog) — español e inglés, toda la UI localizada
- MapKit para búsqueda/selección de direcciones

## Arquitectura

```
ViewController ←→ ViewModel ←→ Service (singleton) ←→ APIClient ←→ nike-store-api
      ↑                                    │
      └──────────── Coordinator ───────────┘
```

- **Coordinators** (`NikeResearch/Coordinators/`) manejan la navegación entre pantallas y son quienes conectan los closures de los ViewModels (ej. `onAddToCart`, `onCheckoutFailed`) con las acciones reales (llamadas a servicios, push/pop de ViewControllers, alerts).
- **Services** (`NikeResearch/Services/`) son singletons con una propiedad cacheada (ej. `CartService.items`) leída sincrónicamente por los ViewModels, más un patrón **multicast observer** (`onXUpdate(_ observer:)`, no un solo closure) para notificar cambios a múltiples suscriptores sin que se pisen entre sí. Todos están respaldados por la API real — nada vive solo en memoria: `CartService`, `FavoritesService`, `AddressService`, `PaymentMethodsService`, `OrdersService`, `NikePlusService`, `ProductsService`. El servicio es la fuente de verdad: los ViewModels leen de su caché en vez de guardar una copia propia.
- **Estado de carga**: los ViewModels que consultan la API exponen un `LoadState` (`loading` / `loaded` / `empty` / `failed`) y un `onStateChanged`. Hace falta el caso `loading` porque la caché de los servicios arranca vacía, y sin él no se puede distinguir "todavía no respondió el servidor" de "está vacío de verdad" — el empty state se mostraba durante toda la petición. La vista compartida es `Views/Components/LoadingOverlayView`.
- **`AuthService`** es la excepción con capa de abstracción: usa un protocolo `AuthRepository`, implementado por `RemoteAuthRepository` (real, producción) o `DummyAuthRepository` (datos locales, sin red).
- **`Services/Networking/`** — capa de red compartida por todos los servicios:
  - `APIClient` — dos `Session` de Alamofire (una autenticada con `AuthTokenInterceptor`, otra pública para login/register/products/health), métodos genéricos `request<T: Decodable>(...)` con completion.
  - `APIEndpoint` — un enum con los ~20 endpoints del contrato (path, método HTTP, si requiere auth).
  - `APIError` — decodifica el envelope de error del backend (`{error:{code,message,type,requestId}}`), conforma `LocalizedError`.
  - `AuthTokenInterceptor` — agrega el Bearer token a cada request; en un 401 refresca el token una sola vez (single-flight, evita loops) y reintenta; si el refresh falla, limpia el Keychain y dispara `onSessionExpired` (fuerza logout).
  - `KeychainTokenStore` — wrapper mínimo sobre `Security` framework para persistir el access/refresh token.
  - `APILogger` — implementa `EventMonitor` de Alamofire, imprime cada request/response con método, URL, status, headers y JSON pretty-printed en la consola de Xcode (solo en builds DEBUG).
  - `DTOs/` — structs `Codable` que mapean 1:1 las respuestas del backend.

## Ambientes (QA / Producción)

Dos schemes de Xcode, mismo target y bundle ID, cada uno con su Build Configuration:

| Scheme | Build Configuration | `API_BASE_URL` |
|---|---|---|
| `NikeResearch-QA` | Debug | `http://localhost:3000` |
| `NikeResearch` | Release | `https://nike-store-api.onrender.com` |

La URL se inyecta vía `.xcconfig` (`NikeResearch/Configuration/QA.xcconfig` / `Production.xcconfig`), sustituida como `$(API_BASE_URL)` en una clave `APIBaseURL` del `Info.plist`, y leída en runtime por `AppConfig.swift` (`Bundle.main.object(forInfoDictionaryKey:)`). Cambiar de ambiente es elegir el scheme desde el dropdown de Xcode — no requiere tocar código.

El timeout de las tres `Session` de Alamofire está en 90s (`URLSessionConfiguration.nikeAPI` en `AppConfig.swift`), más alto que el default de 60s, porque el plan Free de Render apaga la instancia tras ~15 min de inactividad y el cold start puede tardar ese tiempo en responder.

## Funcionalidades

- **Auth**: login/registro contra la API real, tokens en Keychain, refresh automático, logout limpia todo el caché de datos de cuenta (carrito, favoritos, direcciones, tarjetas, pedidos, Nike+).
- **Catálogo (Feed) + Detalle de producto**: datos reales desde `GET /products`, selector de cantidad, botón de compra con loader mientras se agrega al carrito. El carrusel de sugerencias del detalle sale del mismo catálogo, excluyendo el producto que se está viendo.
- **Carrito**: agregar/quitar/ajustar cantidad, persistido en el servidor, badge del tab con el conteo actualizado en cada mutación y al iniciar sesión.
- **Favoritos**: persistidos en el servidor, sobreviven logout/reinstalación.
- **Direcciones**: agregar, **editar** (`PATCH`), eliminar; búsqueda de dirección con MapKit.
- **Tarjetas**: número validado con algoritmo de Luhn, se muestra enmascarado (`**** 1234`) tras completarlo, selector de mes/año nativo (`UIPickerView`), el backend nunca recibe ni devuelve el número completo (solo `cardBrand` + `cardLast4`).
- **Checkout**: `PaymentGateway` mockeado en el backend — tarjetas terminadas en `0002` simulan un rechazo.
- **Historial y detalle de pedidos**, **actividad Nike+**, **perfil**.
- Toda la UI está localizada a español/inglés (`Localizable.xcstrings`), respeta el idioma del dispositivo.

## Estructura del proyecto

```
NikeResearch/
  App/                # AppDelegate (config del proceso) + SceneDelegate (ventana y AppCoordinator)
  Configuration/      # AppConfig.swift, QA.xcconfig, Production.xcconfig
  Coordinators/       # navegación por flujo (Feed, Cart, Favorites, Profile, App)
  Models/             # Shoe, CartItem, PaymentMethod, Address, Order, etc.
  Services/           # singletons de datos + Services/Networking/ (capa HTTP)
  ViewModels/         # un ViewModel por pantalla, + LoadState
  ViewControllers/    # Auth, Feed, ShoeDetail, Cart, Checkout, Favorites, NikePlus, Profile
  Views/Cells/        # celdas reutilizables de tabla/colección
  Views/Components/   # vistas compartidas (LoadingOverlayView, ImageCarouselHeaderView)
  Extensions/         # helpers (alertas, Luhn, fechas ISO8601, formateo de moneda)
  Resources/          # Info.plist, Assets.xcassets
  Localizable.xcstrings
```

La app adopta el ciclo de vida de `UIScene`: la ventana y el `AppCoordinator` los crea el `SceneDelegate`, no el `AppDelegate`. La escena se declara en `UIApplicationSceneManifest` (`Info.plist`), con una sola ventana (`UIApplicationSupportsMultipleScenes = false`).

`Version` y `Build` salen de `MARKETING_VERSION` y `CURRENT_PROJECT_VERSION`, referenciados desde el `Info.plist` como `$(MARKETING_VERSION)` / `$(CURRENT_PROJECT_VERSION)`. Editarlos en Xcode (o en los `.xcconfig`) se refleja en el archive; no hay que tocar el plist a mano.

## Backend

La API vive en un repo separado: [`nike-store-api`](https://github.com/rapser/nike-store-api) — ahí está documentado cómo se configuró Neon (base de datos) y Render (deploy), las variables de entorno, y el contrato de la API. Para desarrollar contra el backend en local:

```bash
# en el repo nike-store-api
npm install
npm run start:dev   # levanta en http://localhost:3000
```

Luego, en Xcode, corre el app con el scheme **`NikeResearch-QA`** para apuntar a ese servidor local.

## Correr el app

1. Abrir `NikeResearch.xcodeproj` en Xcode.
2. Elegir el scheme (`NikeResearch-QA` para local, `NikeResearch` para producción/Render) en el dropdown superior.
3. Run (⌘R).

Usuario demo (mismo backend, ambos ambientes comparten la base de Neon): `jordan@nike.com` / `password123`.
