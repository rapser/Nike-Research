import MapKit

final class AddAddressViewModel {
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var country: String = ""
    var selectedCoordinate: CLLocationCoordinate2D?

    var onSearchResults: (([MKMapItem]) -> Void)?
    var onAddressSelected: (() -> Void)?
    var onAddressSaved: (() -> Void)?

    var title: String { "ADD ADDRESS" }
    var isValid: Bool { !street.isEmpty && !city.isEmpty && !zipCode.isEmpty }

    private var activeSearch: MKLocalSearch?

    func search(query: String) {
        activeSearch?.cancel()
        guard !query.isEmpty else {
            onSearchResults?([])
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address
        let search = MKLocalSearch(request: request)
        activeSearch = search
        search.start { [weak self] response, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.onSearchResults?(response?.mapItems ?? [])
            }
        }
    }

    func selectMapItem(_ item: MKMapItem) {
        let p = item.placemark
        street = [p.subThoroughfare, p.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
        city = p.locality ?? ""
        state = p.administrativeArea ?? ""
        zipCode = p.postalCode ?? ""
        country = p.country ?? ""
        selectedCoordinate = p.coordinate
        onAddressSelected?()
    }

    func saveAddress() {
        let coord = selectedCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let address = Address(
            id: UUID().uuidString,
            street: street,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country,
            latitude: coord.latitude,
            longitude: coord.longitude
        )
        AddressService.shared.add(address)
        onAddressSaved?()
    }
}
