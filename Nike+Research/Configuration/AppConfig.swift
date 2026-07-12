import Foundation

/// Reads `APIConfig.plist` once at startup. Swap the `BaseURL` value in that
/// plist (dev → `http://localhost:3000`, prod → the Render URL) without touching code.
enum AppConfig {
    static let baseURL: URL = {
        guard
            let url = Bundle.main.url(forResource: "APIConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
            let baseURLString = plist["BaseURL"],
            let baseURL = URL(string: baseURLString)
        else {
            fatalError("APIConfig.plist is missing or malformed — expected a BaseURL string key.")
        }
        return baseURL
    }()
}
