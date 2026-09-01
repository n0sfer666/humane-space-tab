import AppKit
import SwitcherCore

/// What the panel is made of: the style, and the single number that style can act on. The
/// number keeps its own row so the label can say what it means at the time — a scrim on
/// glass, an opacity on a plain panel — instead of one word covering both.
@MainActor
final class AppearanceBackgroundView: NSView {
    private let center: AppearanceCenter
    private let styles = NSPopUpButton(frame: .zero, pullsDown: false)
    private let levelTitle = SettingsGrid.label("")
    private lazy var level = MeasureRow(unit: .percent) { [weak self] value in
        self?.changed(level: value)
    }

    init(center: AppearanceCenter) {
        self.center = center
        super.init(frame: .zero)
        styles.addItems(withTitles: BackgroundChoice.allCases.map(\.title))
        styles.target = self
        styles.action = #selector(pickedStyle)
        SettingsGrid.install(
            SettingsGrid.make([
                [SettingsGrid.label(Localised.text(.appearanceBackground)), styles],
                [levelTitle, level],
            ]),
            in: self
        )
        center.observe { [weak self] in self?.show($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var shownChoice: BackgroundChoice? { BackgroundChoice(rawValue: styles.indexOfSelectedItem) }

    var shownLevel: Double { level.value }

    var shownLevelTitle: String { levelTitle.stringValue }

    var isEditable: Bool { styles.isEnabled }

    func choose(_ choice: BackgroundChoice) {
        styles.selectItem(at: choice.rawValue)
        pickedStyle()
    }

    func change(level value: Double) {
        changed(level: value)
    }

    @objc
    private func pickedStyle() {
        guard let choice = shownChoice else { return }
        center.edit { $0.with(background: choice.standard) }
        show(center.book)
    }

    private func changed(level value: Double) {
        center.edit { $0.with(background: $0.background.with(level: value)) }
        show(center.book)
    }

    private func show(_ book: AppearanceBook) {
        let background = book.active.appearance.background
        let choice = BackgroundChoice(background)
        styles.selectItem(at: choice.rawValue)
        styles.isEnabled = book.isEditable
        levelTitle.stringValue = choice.levelTitle
        level.show(background.level, range: background.range, enabled: book.isEditable)
    }
}
