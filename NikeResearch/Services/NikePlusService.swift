import Foundation

/// Backed by `GET /nikeplus/activities` — replaces `NikePlusProfile.dummy()`,
/// which was fully hardcoded (no service layer at all). The "profile" half
/// (name, member since) isn't NikePlus-specific data on the backend — it comes
/// straight from `AuthService.currentUser`, same as the Profile tab.
final class NikePlusService {
    static let shared = NikePlusService()
    private init() {}

    private(set) var activities: [NikePlusActivity] = []
    var onActivitiesUpdated: (() -> Void)?

    func fetchActivities(completion: @escaping (Error?) -> Void) {
        APIClient.shared.request(.nikePlusActivities, decode: [NikePlusActivityDTO].self) { [weak self] result in
            switch result {
            case .success(let dtos):
                self?.activities = dtos.map { NikePlusActivity(title: $0.title, value: $0.value, unit: $0.unit) }
                self?.onActivitiesUpdated?()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    /// Local-only reset, no network call — used on logout.
    func clearAll() {
        activities = []
        onActivitiesUpdated?()
    }
}
