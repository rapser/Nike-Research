import UIKit

final class NikePlusViewModel {
    private let profile: NikePlusProfile = .dummy()

    var title: String { "NIKE+" }
    var memberName: String { profile.name }
    var memberSince: String { profile.memberSince }
    var avatarImage: UIImage? { UIImage(named: profile.avatarImageName) }
    var activityCount: Int { profile.activities.count }

    func activityTitle(at index: Int) -> String { profile.activities[index].title }
    func activityValue(at index: Int) -> String { profile.activities[index].value }
    func activityUnit(at index: Int) -> String { profile.activities[index].unit }
}
