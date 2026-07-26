final class AppearanceViewModel {
    var onSelectionChanged: (() -> Void)?

    private let modes = AppearanceMode.allCases

    var title: String { String(localized: "APPEARANCE") }
    var footer: String { String(localized: "System uses the appearance set on your device.") }
    var count: Int { modes.count }

    func title(at index: Int) -> String { modes[index].title }
    func symbol(at index: Int) -> String { modes[index].sfSymbol }
    func isSelected(at index: Int) -> Bool { modes[index] == AppearanceService.shared.mode }

    func selectMode(at index: Int) {
        guard modes[index] != AppearanceService.shared.mode else { return }
        AppearanceService.shared.setMode(modes[index])
        onSelectionChanged?()
    }
}
