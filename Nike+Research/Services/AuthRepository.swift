import Foundation

/// Contract for authentication operations. `DummyAuthRepository` is in-memory/no network;
/// `RemoteAuthRepository` talks to `nike-store-api` via `APIClient`. `AuthService` picks
/// the implementation, so ViewModels/ViewControllers never know which one is active.
protocol AuthRepository {
    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void)
    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void)

    /// Best-effort, fire-and-forget: `DummyAuthRepository` no-ops; `RemoteAuthRepository`
    /// clears the Keychain and revokes the refresh token server-side without blocking
    /// the local logout `AuthService` already performs synchronously.
    func logout()
}
