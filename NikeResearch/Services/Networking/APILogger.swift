import Alamofire
import Foundation

/// Logs every request that goes through any `Session` it's attached to — method,
/// full URL, status, request headers, and pretty-printed request/response JSON.
/// DEBUG builds only, so tokens/passwords never end up in a release build's
/// device logs. Attach to every `Session` in `APIClient`/`AuthTokenInterceptor`
/// for full coverage, including the token refresh call.
final class APILogger: EventMonitor {
    let queue = DispatchQueue(label: "com.nikeapp.Nike-Research.APILogger")

    /// Fires when Alamofire fails to build the `URLRequest` itself (e.g. a
    /// parameter-encoding error) — *before* anything is sent over the network,
    /// so `didParseResponse` never runs for it. Without this override those
    /// requests fail completely silently.
    func request(_ request: Request, didFailToCreateURLRequestWithError error: Error) {
        #if DEBUG
        print([
            "🔥 NETWORK: Nike+Research API",
            "🚫 FAILED TO CREATE REQUEST: \(request.description)",
            "⚠️ ERROR: \(error)"
        ].joined(separator: "\n"))
        #endif
    }

    /// `.responseData { }` produces `DataResponse<Data, AFError>` — the *generic*
    /// overload below is the one that actually fires for it. `EventMonitor` also
    /// declares a non-generic `DataResponse<Data?, AFError>` overload for other
    /// serializers; without this generic one, logging silently falls back to the
    /// protocol's empty default and never prints.
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
        let urlRequest = response.request
        let method = urlRequest?.httpMethod ?? "?"
        let url = urlRequest?.url?.absoluteString ?? "?"
        let statusCode = response.response?.statusCode
        let statusEmoji = statusCode.map { (200..<300).contains($0) ? "✅" : "❌" } ?? "❌"
        let statusText = statusCode.map(String.init) ?? "?"

        var lines = [
            "🔥 NETWORK: Nike+Research API",
            "🧭 METHOD: \(method)",
            "🌍 URL: \(url)",
            "\(statusEmoji) STATUS: \(statusText)"
        ]

        if let headers = urlRequest?.allHTTPHeaderFields, !headers.isEmpty {
            lines.append("")
            lines.append("📤 REQUEST HEADERS:")
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                lines.append("   \(key): \(value)")
            }
        }

        if let body = urlRequest?.httpBody, let prettyBody = Self.prettyPrintedJSON(from: body) {
            lines.append("")
            lines.append("📦 REQUEST BODY:")
            lines.append(prettyBody)
        }

        if let data = response.data, let prettyResponse = Self.prettyPrintedJSON(from: data) {
            lines.append("")
            lines.append("📝 RESPONSE JSON:")
            lines.append(prettyResponse)
        }

        if case .failure(let error) = response.result {
            lines.append("")
            lines.append("⚠️ ERROR: \(error)")
        }

        print(lines.joined(separator: "\n"))
        #endif
    }

    private static func prettyPrintedJSON(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: prettyData, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8)
        }
        return string
    }
}
