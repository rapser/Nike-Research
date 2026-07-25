final class MyAddressesViewModel {
    var onAddressesChanged: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

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
        state = .loading
        AddressService.shared.fetchAddresses { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.isEmpty ? .empty : .loaded)
            completion(error)
        }
    }

    func address(at index: Int) -> Address { addresses[index] }

    func remove(at index: Int, completion: ((Error?) -> Void)? = nil) {
        AddressService.shared.remove(at: index, completion: completion)
    }
}
