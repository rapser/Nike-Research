final class AddressService {
    static let shared = AddressService()
    private init() {}

    private(set) var addresses: [Address] = []
    var onAddressesUpdated: (() -> Void)?

    func add(_ address: Address) {
        addresses.append(address)
        onAddressesUpdated?()
    }

    func remove(at index: Int) {
        guard index < addresses.count else { return }
        addresses.remove(at: index)
        onAddressesUpdated?()
    }
}
