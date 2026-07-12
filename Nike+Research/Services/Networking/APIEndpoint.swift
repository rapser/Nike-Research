import Alamofire

/// One case per route documented in `CONTRACT.md`.
enum APIEndpoint {
    case register
    case login
    case refresh
    case logout
    case me

    case products
    case product(id: String)

    case cart
    case addCartItem
    case updateCartItem(id: String)
    case removeCartItem(id: String)
    case clearCart

    case favorites
    case addFavorite
    case removeFavorite(productId: String)

    case paymentMethods
    case createPaymentMethod
    case removePaymentMethod(id: String)

    case addresses
    case createAddress
    case updateAddress(id: String)
    case removeAddress(id: String)

    case orders
    case createOrder

    case nikePlusActivities

    var path: String {
        switch self {
        case .register: return "/auth/register"
        case .login: return "/auth/login"
        case .refresh: return "/auth/refresh"
        case .logout: return "/auth/logout"
        case .me: return "/auth/me"

        case .products: return "/products"
        case .product(let id): return "/products/\(id)"

        case .cart: return "/cart"
        case .addCartItem: return "/cart/items"
        case .updateCartItem(let id): return "/cart/items/\(id)"
        case .removeCartItem(let id): return "/cart/items/\(id)"
        case .clearCart: return "/cart"

        case .favorites: return "/favorites"
        case .addFavorite: return "/favorites"
        case .removeFavorite(let productId): return "/favorites/\(productId)"

        case .paymentMethods: return "/payment-methods"
        case .createPaymentMethod: return "/payment-methods"
        case .removePaymentMethod(let id): return "/payment-methods/\(id)"

        case .addresses: return "/addresses"
        case .createAddress: return "/addresses"
        case .updateAddress(let id): return "/addresses/\(id)"
        case .removeAddress(let id): return "/addresses/\(id)"

        case .orders: return "/orders"
        case .createOrder: return "/orders"

        case .nikePlusActivities: return "/nikeplus/activities"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .refresh, .logout, .addCartItem, .addFavorite, .createPaymentMethod, .createAddress, .createOrder:
            return .post
        case .updateCartItem, .updateAddress:
            return .patch
        case .removeCartItem, .clearCart, .removeFavorite, .removePaymentMethod, .removeAddress:
            return .delete
        case .me, .products, .product, .cart, .favorites, .paymentMethods, .addresses, .orders, .nikePlusActivities:
            return .get
        }
    }

    /// Public routes hit `APIClient`'s un-intercepted session (no Bearer token attached).
    var requiresAuth: Bool {
        switch self {
        case .register, .login, .refresh, .products, .product:
            return false
        default:
            return true
        }
    }
}
