import Alamofire
import Foundation

/// Thin wrapper around two Alamofire `Session`s (one carrying `AuthTokenInterceptor`
/// for protected routes, one plain for public routes) that speaks the same
/// completion-handler style the rest of the codebase already uses — no async/await
/// or Combine, to avoid mixing concurrency paradigms in one small app.
final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = AppConfig.baseURL
    private let authenticatedSession = Session(configuration: .nikeAPI, interceptor: AuthTokenInterceptor.shared, eventMonitors: [APILogger()])
    private let publicSession = Session(configuration: .nikeAPI, eventMonitors: [APILogger()])

    private func session(for endpoint: APIEndpoint) -> Session {
        endpoint.requiresAuth ? authenticatedSession : publicSession
    }

    private func url(for endpoint: APIEndpoint) -> URL {
        baseURL.appendingPathComponent(endpoint.path)
    }

    /// Corta cualquier llamada a una ruta protegida cuando no hay sesión, antes de tocar
    /// la red. Sin esto, un invitado dispara un 401 que además despierta al
    /// `AuthTokenInterceptor` a refrescar un token que no existe.
    ///
    /// Es la red de seguridad: lo correcto es que las pantallas ni lo intenten (ver los
    /// `guard` de los ViewModels), pero esto garantiza que ninguna ruta protegida se
    /// escape, incluidas las que se añadan después. Devuelve en el hilo principal y de
    /// forma asíncrona para que los llamadores vean la misma semántica que con una
    /// respuesta real de red.
    private func rejectUnauthenticated<T>(
        _ endpoint: APIEndpoint,
        completion: @escaping (Result<T, APIError>) -> Void
    ) -> Bool {
        guard endpoint.requiresAuth, !AuthService.shared.isAuthenticated else { return false }
        DispatchQueue.main.async { completion(.failure(.notAuthenticated)) }
        return true
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        decode: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard !rejectUnauthenticated(endpoint, completion: completion) else { return }
        session(for: endpoint)
            .request(url(for: endpoint), method: endpoint.method)
            .validate()
            .responseData { self.handle($0, completion: completion) }
    }

    func request<T: Decodable, B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B,
        decode: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard !rejectUnauthenticated(endpoint, completion: completion) else { return }
        session(for: endpoint)
            .request(url(for: endpoint), method: endpoint.method, parameters: body, encoder: JSONParameterEncoder.default)
            .validate()
            .responseData { self.handle($0, completion: completion) }
    }

    /// For endpoints with no meaningful response body (e.g. `204` on logout).
    func requestVoid<B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        guard !rejectUnauthenticated(endpoint, completion: completion) else { return }
        session(for: endpoint)
            .request(url(for: endpoint), method: endpoint.method, parameters: body, encoder: JSONParameterEncoder.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure:
                    completion(.failure(self.decodeError(from: response.data)))
                }
            }
    }

    private func handle<T: Decodable>(_ response: AFDataResponse<Data>, completion: @escaping (Result<T, APIError>) -> Void) {
        switch response.result {
        case .success(let data):
            if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                completion(.success(decoded))
            } else {
                completion(.failure(.decoding))
            }
        case .failure:
            completion(.failure(decodeError(from: response.data)))
        }
    }

    private func decodeError(from data: Data?) -> APIError {
        guard let data, let apiError = try? JSONDecoder().decode(APIError.self, from: data) else {
            return .network
        }
        return apiError
    }
}
