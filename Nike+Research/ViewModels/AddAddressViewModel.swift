import MapKit

final class AddAddressViewModel {
    private let editingAddressID: String?

    var street: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var country: String = ""
    var selectedCoordinate: CLLocationCoordinate2D?

    var onSearchResults: (([MKMapItem]) -> Void)?
    var onAddressSelected: (() -> Void)?
    var onAddressSaved: (() -> Void)?

    /// Pass an existing `Address` to edit it in place (`PATCH`); omit it to add
    /// a new one (`POST`) — same form, same screen, just a different save call.
    init(editing address: Address? = nil) {
        editingAddressID = address?.id
        if let address {
            street = address.street
            city = address.city
            state = address.state
            zipCode = address.zipCode
            country = address.country
            selectedCoordinate = address.coordinate
        }
    }

    var title: String { editingAddressID == nil ? String(localized: "ADD ADDRESS") : String(localized: "EDIT ADDRESS") }
    var saveButtonTitle: String { editingAddressID == nil ? String(localized: "SAVE ADDRESS") : String(localized: "SAVE CHANGES") }
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

    func saveAddress(completion: @escaping (Error?) -> Void) {
        let coord = selectedCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)

        let handleResult: (Error?) -> Void = { [weak self] error in
            if error == nil {
                self?.onAddressSaved?()
            }
            completion(error)
        }

        if let editingAddressID {
            AddressService.shared.update(
                id: editingAddressID, street: street, city: city, state: state, zipCode: zipCode,
                country: country, latitude: coord.latitude, longitude: coord.longitude,
                completion: handleResult
            )
        } else {
            AddressService.shared.add(
                street: street, city: city, state: state, zipCode: zipCode, country: country,
                latitude: coord.latitude, longitude: coord.longitude,
                completion: handleResult
            )
        }
    }
}
