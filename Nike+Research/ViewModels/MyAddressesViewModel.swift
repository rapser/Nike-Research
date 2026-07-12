final class MyAddressesViewModel {
    var onAddressesChanged: (() -> Void)?

    init() {
        AddressService.shared.onAddressesUpdate { [weak self] in
            self?.onAddressesChanged?()
        }
    }

    var title: String { String(localized: "MY ADDRESSES") }
    var addresses: [Address] { AddressService.shared.addresses }
    var count: Int { addresses.count }
    var isEmpty: Bool { addresses.isEmpty }

    func loadAddresses(completion: @escaping (Error?) -> Void) {
        AddressService.shared.fetchAddresses(completion: completion)
    }

    func address(at index: Int) -> Address { addresses[index] }

    func remove(at index: Int, completion: ((Error?) -> Void)? = nil) {
        AddressService.shared.remove(at: index, completion: completion)
    }
}
