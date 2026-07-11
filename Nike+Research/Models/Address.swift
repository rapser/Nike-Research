import CoreLocation

struct Address {
    let id: String
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var displayTitle: String { street.isEmpty ? "Unknown address" : street }
    var displaySubtitle: String { "\(city), \(state) \(zipCode)" }
    var fullAddress: String {
        [street, city, "\(state) \(zipCode)", country]
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: ", ")
    }
}
