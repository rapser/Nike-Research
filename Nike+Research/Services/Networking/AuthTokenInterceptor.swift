import Alamofire
import Foundation
import Synchronization

/// Attaches the Bearer access token to every authenticated request. On a 401,
/// refreshes the token pair once (single-flight — concurrent 401s share one
/// refresh call) and retries; if the refresh itself fails, clears the Keychain
/// and notifies `onSessionExpired` so the app can drop back to the login screen.
///
/// All mutable state lives inside a single `Mutex<State>` (Swift 6's
/// `Synchronization` module, iOS 18+) — access is only possible through
/// `withLock`, so the compiler can verify `Sendable` for real, no `@unchecked`
/// escape hatch needed.
final class AuthTokenInterceptor: RequestInterceptor, Sendable {
    static let shared = AuthTokenInterceptor()
    private init() {}

    private struct State {
        var isRefreshing = false
        var pendingRetries: [(RetryResult) -> Void] = []
        var onSessionExpired: (() -> Void)?
    }

    private let refreshSession = Session(configuration: .nikeAPI, eventMonitors: [APILogger()])
    private let state = Mutex(State())

    var onSessionExpired: (() -> Void)? {
        get { state.withLock { $0.onSessionExpired } }
        set { state.withLock { $0.onSessionExpired = newValue } }
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        if let token = KeychainTokenStore.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard
            let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            request.retryCount == 0
        else {
            completion(.doNotRetry)
            return
        }

        let shouldStartRefresh = state.withLock { state -> Bool in
            state.pendingRetries.append(completion)
            let shouldStart = !state.isRefreshing
            state.isRefreshing = true
            return shouldStart
        }

        if shouldStartRefresh {
            performRefresh()
        }
    }

    private func performRefresh() {
        guard let refreshToken = KeychainTokenStore.shared.refreshToken else {
            finishRefresh(success: false)
            return
        }

        let url = AppConfig.baseURL.appendingPathComponent("auth/refresh")
        refreshSession
            .request(url, method: .post, parameters: RefreshRequestDTO(refreshToken: refreshToken), encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: AuthResponseDTO.self) { [weak self] response in
                switch response.result {
                case .success(let auth):
                    KeychainTokenStore.shared.saveTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken)
                    self?.finishRefresh(success: true)
                case .failure:
                    self?.finishRefresh(success: false)
                }
            }
    }

    private func finishRefresh(success: Bool) {
        let callbacks = state.withLock { state -> [(RetryResult) -> Void] in
            let callbacks = state.pendingRetries
            state.pendingRetries = []
            state.isRefreshing = false
            return callbacks
        }

        if !success {
            KeychainTokenStore.shared.clear()
            DispatchQueue.main.async { [weak self] in self?.onSessionExpired?() }
        }

        callbacks.forEach { $0(success ? .retry : .doNotRetry) }
    }
}
