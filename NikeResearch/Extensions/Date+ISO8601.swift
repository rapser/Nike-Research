import Foundation

extension Date {
    /// The backend serializes dates via JS's `Date.toISOString()`, which always
    /// includes milliseconds (`...ss.sssZ`). The default `ISO8601DateFormatter`
    /// options don't parse that and silently return nil, so this is the one to
    /// use for any date string coming from the API.
    static func fromAPI(_ isoString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: isoString)
    }
}
