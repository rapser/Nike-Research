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
    private let authenticatedSession = Session(interceptor: AuthTokenInterceptor.shared, eventMonitors: [APILogger()])
    private let publicSession = Session(eventMonitors: [APILogger()])

    private func session(for endpoint: APIEndpoint) -> Session {
        endpoint.requiresAuth ? authenticatedSession : publicSession
    }

    private func url(for endpoint: APIEndpoint) -> URL {
        baseURL.appendingPathComponent(endpoint.path)
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        decode: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
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
