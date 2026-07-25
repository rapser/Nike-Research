import Alamofire
import Foundation

/// Reads the `APIBaseURL` Info.plist key, which Xcode resolves at build time
/// from the active Build Configuration's `.xcconfig` (`QA.xcconfig` for
/// Debug → localhost, `Production.xcconfig` for Release → Render) — no code
/// change needed to switch environments, just the build configuration.
enum AppConfig {
    static let baseURL: URL = {
        guard
            let baseURLString = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
            let baseURL = URL(string: baseURLString)
        else {
            fatalError("APIBaseURL is missing or malformed in Info.plist — check that the active Build Configuration has a base .xcconfig with API_BASE_URL set.")
        }
        return baseURL
    }()
}

extension URLSessionConfiguration {
    /// Longer than Alamofire's default (60s) — Render's free tier spins the
    /// API down after inactivity, and waking it back up (cold start) can take
    /// longer than 60s, which would otherwise time out the very request that
    /// triggers the wake-up.
    static var nikeAPI: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 90
        return configuration
    }
}
