final class ProfileViewModel {
    var title: String { String(localized: "MY ACCOUNT") }

    var isAuthenticated: Bool { AuthService.shared.isAuthenticated }
    var memberName: String { AuthService.shared.currentUser?.name ?? "" }
    var memberEmail: String { AuthService.shared.currentUser?.email ?? "" }
    var memberSince: String { AuthService.shared.currentUser?.memberSince ?? "" }
}
