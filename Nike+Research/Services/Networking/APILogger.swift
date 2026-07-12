import Alamofire
import Foundation

/// Logs every request that goes through any `Session` it's attached to —
/// method, full URL, request body, status code, and response body. DEBUG
/// builds only, so tokens/passwords never end up in a release build's
/// device logs. Attach to every `Session` in `APIClient`/`AuthTokenInterceptor`
/// for full coverage, including the token refresh call.
final class APILogger: EventMonitor {
    let queue = DispatchQueue(label: "com.nikeapp.Nike-Research.APILogger")

    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        #if DEBUG
        var lines = ["➡️ \(urlRequest.httpMethod ?? "?") \(urlRequest.url?.absoluteString ?? "?")"]
        if let body = urlRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            lines.append("   body: \(bodyString)")
        }
        print(lines.joined(separator: "\n"))
        #endif
    }

    /// `.responseData { }` produces `DataResponse<Data, AFError>` — the *generic*
    /// overload below is the one that actually fires for it. `EventMonitor` also
    /// declares a non-generic `DataResponse<Data?, AFError>` overload for other
    /// serializers; without this generic one, logging silently falls back to the
    /// protocol's empty default and only `didCreateURLRequest` ever prints.
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
        let urlString = response.request?.url?.absoluteString ?? "?"
        let statusCode: Int? = response.response?.statusCode
        let status = statusCode.map(String.init) ?? "?"
        var lines = ["⬅️ \(status) \(urlString)"]
        if let data = response.data, let bodyString = String(data: data, encoding: .utf8) {
            lines.append("   response: \(bodyString)")
        }
        if case .failure(let error) = response.result {
            lines.append("   error: \(error)")
        }
        print(lines.joined(separator: "\n"))
        #endif
    }
}
