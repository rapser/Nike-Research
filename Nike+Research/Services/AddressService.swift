import Foundation

/// Backed by `GET/POST/PATCH/DELETE /addresses` — previously pure in-memory
/// (client-generated UUIDs, never persisted). Same cached-property + multicast-
/// observer shape as `CartService`/`FavoritesService`.
final class AddressService {
    static let shared = AddressService()
    private init() {}

    private(set) var addresses: [Address] = []

    private var updateObservers: [() -> Void] = []
    func onAddressesUpdate(_ observer: @escaping () -> Void) {
        updateObservers.append(observer)
    }
    private func notifyUpdated() {
        updateObservers.forEach { $0() }
    }

    func fetchAddresses(completion: @escaping (Error?) -> Void) {
        APIClient.shared.request(.addresses, decode: [AddressDTO].self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    /// Unlike `fetchAddresses`/`remove`, `POST /addresses` returns just the
    /// created address, not the full list — append it locally instead of
    /// replacing the cache.
    func add(street: String, city: String, state: String, zipCode: String, country: String,
             latitude: Double, longitude: Double, completion: @escaping (Error?) -> Void) {
        let body = CreateAddressRequestDTO(
            street: street, city: city, state: state, zipCode: zipCode, country: country,
            latitude: latitude, longitude: longitude, isDefault: nil
        )
        APIClient.shared.request(.createAddress, body: body, decode: AddressDTO.self) { [weak self] result in
            switch result {
            case .success(let dto):
                self?.addresses.append(Self.toAddress(dto))
                self?.notifyUpdated()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    /// Like `add`, `PATCH /addresses/:id` returns just the updated address —
    /// swap it into the cache at the same position instead of replacing the list.
    func update(id: String, street: String, city: String, state: String, zipCode: String, country: String,
                latitude: Double, longitude: Double, completion: @escaping (Error?) -> Void) {
        let body = CreateAddressRequestDTO(
            street: street, city: city, state: state, zipCode: zipCode, country: country,
            latitude: latitude, longitude: longitude, isDefault: nil
        )
        APIClient.shared.request(.updateAddress(id: id), body: body, decode: AddressDTO.self) { [weak self] result in
            switch result {
            case .success(let dto):
                if let index = self?.addresses.firstIndex(where: { $0.id == id }) {
                    self?.addresses[index] = Self.toAddress(dto)
                }
                self?.notifyUpdated()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func remove(at index: Int, completion: ((Error?) -> Void)? = nil) {
        guard index < addresses.count else { return }
        let id = addresses[index].id
        APIClient.shared.request(.removeAddress(id: id), decode: [AddressDTO].self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    /// Local-only reset, no network call — used on logout.
    func clearAll() {
        addresses = []
        notifyUpdated()
    }

    private func handle(_ result: Result<[AddressDTO], APIError>, completion: ((Error?) -> Void)?) {
        switch result {
        case .success(let dtos):
            addresses = dtos.map(Self.toAddress)
            notifyUpdated()
            completion?(nil)
        case .failure(let error):
            completion?(error)
        }
    }

    private static func toAddress(_ dto: AddressDTO) -> Address {
        Address(
            id: dto.id, street: dto.street, city: dto.city, state: dto.state, zipCode: dto.zipCode,
            country: dto.country, latitude: dto.latitude, longitude: dto.longitude
        )
    }
}
