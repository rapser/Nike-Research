import UIKit

final class NikePlusViewModel {
    var onActivitiesChanged: (() -> Void)?

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
        NikePlusService.shared.fetchActivities(completion: completion)
    }

    func activityTitle(at index: Int) -> String { NikePlusService.shared.activities[index].title }
    func activityValue(at index: Int) -> String { NikePlusService.shared.activities[index].value }
    func activityUnit(at index: Int) -> String { NikePlusService.shared.activities[index].unit }
}
