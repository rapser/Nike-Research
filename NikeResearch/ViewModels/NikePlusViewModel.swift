import UIKit

final class NikePlusViewModel {
    var onActivitiesChanged: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    init() {
        NikePlusService.shared.onActivitiesUpdated = { [weak self] in
            self?.onActivitiesChanged?()
        }
    }

    var title: String { String(localized: "NIKE+") }
    var memberName: String { AuthService.shared.currentUser?.name ?? String(localized: "Guest") }
    var memberSince: String { AuthService.shared.currentUser?.memberSince ?? "" }
    var avatarImage: UIImage? { UIImage(named: "s1") }
    var activityCount: Int { NikePlusService.shared.activities.count }

    func loadActivities(completion: @escaping (Error?) -> Void) {
        state = .loading
        NikePlusService.shared.fetchActivities { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.activityCount == 0 ? .empty : .loaded)
            completion(error)
        }
    }

    func activityTitle(at index: Int) -> String { NikePlusService.shared.activities[index].title }
    func activityValue(at index: Int) -> String { NikePlusService.shared.activities[index].value }
    func activityUnit(at index: Int) -> String { NikePlusService.shared.activities[index].unit }
}
