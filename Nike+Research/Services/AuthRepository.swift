import Foundation

/// Contract for authentication operations. Phase 1 is backed by `DummyAuthRepository`
/// (in-memory, no network). Phase 2 can introduce a `RemoteAuthRepository` that talks to a
/// real backend via `URLSession`/`Codable` without requiring any changes to `AuthService`,
/// the ViewModels, or the ViewControllers.
protocol AuthRepository {
    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void)
    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void)
}
