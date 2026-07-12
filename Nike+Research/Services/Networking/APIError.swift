import Foundation

/// Decodes the fintech-style error envelope every `nike-store-api` error response uses:
/// `{"error":{"code","message","type","requestId","details"?}}`. `message` already comes
/// localized from the server (`es` by default), so `errorDescription` can feed straight
/// into the existing `presentAlert(message:)` pattern without any client-side i18n.
struct APIErrorDetail: Decodable {
    let field: String
    let code: String
    let message: String
}

struct APIError: Decodable, LocalizedError {
    let code: String
    let message: String
    let type: String
    let requestId: String
    let details: [APIErrorDetail]?

    private enum CodingKeys: String, CodingKey { case error }
    private enum ErrorKeys: String, CodingKey { case code, message, type, requestId, details }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
        code = try errorContainer.decode(String.self, forKey: .code)
        message = try errorContainer.decode(String.self, forKey: .message)
        type = try errorContainer.decode(String.self, forKey: .type)
        requestId = try errorContainer.decode(String.self, forKey: .requestId)
        details = try errorContainer.decodeIfPresent([APIErrorDetail].self, forKey: .details)
    }

    init(code: String, message: String, type: String = "api_error", requestId: String = "req_local") {
        self.code = code
        self.message = message
        self.type = type
        self.requestId = requestId
        self.details = nil
    }

    var errorDescription: String? { message }

    /// Fallback used when a response can't be decoded as the error envelope at all
    /// (e.g. the server is unreachable, or returns something unexpected).
    static let network = APIError(code: "NETWORK_ERROR", message: "No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.")
    static let decoding = APIError(code: "DECODING_ERROR", message: "Ocurrió un error inesperado procesando la respuesta del servidor.")
}
