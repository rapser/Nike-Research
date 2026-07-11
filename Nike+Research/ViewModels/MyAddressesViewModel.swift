final class MyAddressesViewModel {
    var onAddressesChanged: (() -> Void)?

    init() {
        AddressService.shared.onAddressesUpdated = { [weak self] in
            self?.onAddressesChanged?()
        }
    }

    var title: String { "MY ADDRESSES" }
    var addresses: [Address] { AddressService.shared.addresses }
    var count: Int { addresses.count }
    var isEmpty: Bool { addresses.isEmpty }

    func address(at index: Int) -> Address { addresses[index] }
    func remove(at index: Int) { AddressService.shared.remove(at: index) }
}
