import Foundation

/// In-memory + UserDefaults-backed session store, following the same singleton pattern as
/// `CartService`/`FavoritesService`. All auth operations are delegated to an injected
/// `AuthRepository`, so swapping `DummyAuthRepository` for a real network-backed repository
/// in a later phase requires no changes here or in any caller.
final class AuthService {
    static let shared = AuthService()

    private let repository: AuthRepository
    private let userDefaultsKey = "nike.auth.currentUser"

    private(set) var currentUser: User? {
        didSet { onAuthStateChanged?() }
    }

    var isAuthenticated: Bool { currentUser != nil }
    var onAuthStateChanged: (() -> Void)?

    init(repository: AuthRepository = DummyAuthRepository()) {
        self.repository = repository
        self.currentUser = Self.loadPersistedUser(key: userDefaultsKey)
    }

    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        repository.login(email: email, password: password) { [weak self] result in
            self?.handle(result: result, completion: completion)
        }
    }

    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        repository.register(name: name, email: email, password: password) { [weak self] result in
            self?.handle(result: result, completion: completion)
        }
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    private func handle(result: Result<User, AuthError>, completion: @escaping (Result<User, AuthError>) -> Void) {
        if case .success(let user) = result {
            currentUser = user
            persist(user: user)
        }
        completion(result)
    }

    private func persist(user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    private static func loadPersistedUser(key: String) -> User? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
}
