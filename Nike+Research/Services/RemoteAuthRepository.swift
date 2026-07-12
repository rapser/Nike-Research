import Foundation

/// Talks to `nike-store-api` via `APIClient`. Saves the token pair to the Keychain
/// on every successful login/register/refresh; `AuthService`/ViewModels never see
/// tokens at all, matching the `Result<User, AuthError>` contract `DummyAuthRepository`
/// already established.
final class RemoteAuthRepository: AuthRepository {
    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        let body = LoginRequestDTO(email: email, password: password)
        APIClient.shared.request(.login, body: body, decode: AuthResponseDTO.self) { result in
            self.handle(result: result, completion: completion)
        }
    }

    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        let body = RegisterRequestDTO(name: name, email: email, password: password)
        APIClient.shared.request(.register, body: body, decode: AuthResponseDTO.self) { result in
            self.handle(result: result, completion: completion)
        }
    }

    func logout() {
        guard let refreshToken = KeychainTokenStore.shared.refreshToken else {
            KeychainTokenStore.shared.clear()
            return
        }
        APIClient.shared.requestVoid(.logout, body: RefreshRequestDTO(refreshToken: refreshToken)) { _ in
            KeychainTokenStore.shared.clear()
        }
    }

    private func handle(result: Result<AuthResponseDTO, APIError>, completion: @escaping (Result<User, AuthError>) -> Void) {
        switch result {
        case .success(let auth):
            KeychainTokenStore.shared.saveTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken)
            let user = User(id: auth.user.id, name: auth.user.name, email: auth.user.email, memberSince: Self.formatMemberSince(auth.user.memberSince))
            completion(.success(user))
        case .failure(let apiError):
            completion(.failure(mapError(apiError)))
        }
    }

    /// The server sends a raw ISO 8601 timestamp; `DummyAuthRepository` already
    /// established "Member since <year>" as the format `User.memberSince` carries,
    /// so match it here instead of showing the raw string.
    private static func formatMemberSince(_ isoString: String) -> String {
        guard let date = Date.fromAPI(isoString) else { return "Member since \(isoString)" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return "Member since \(formatter.string(from: date))"
    }

    private func mapError(_ apiError: APIError) -> AuthError {
        switch apiError.code {
        case "EMAIL_ALREADY_IN_USE": return .emailAlreadyInUse
        case "INVALID_CREDENTIALS": return .invalidCredentials
        case "VALIDATION_ERROR": return .invalidForm
        default: return .unknown
        }
    }
}
