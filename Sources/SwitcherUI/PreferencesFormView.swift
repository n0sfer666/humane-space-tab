import AppKit
import SwitcherCore

@MainActor
final class PreferencesFormView: NSView {
    private let screens = NSPopUpButton()
    private let delay = NSSlider()
    private let delayValue = NSTextField(labelWithString: "")
    private let privateLayer = NSButton(checkboxWithTitle: "Use the private Space layer", target: nil, action: nil)
    private let onChange: @MainActor (Preferences) -> Void

    init(preferences: Preferences, onChange: @escaping @MainActor (Preferences) -> Void) {
        self.onChange = onChange
        super.init(frame: .zero)
        buildScreens()
        buildDelay()
        privateLayer.target = self
        privateLayer.action = #selector(edited)
        install(grid())
        show(preferences)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func show(_ preferences: Preferences) {
        screens.selectItem(at: OverlayScreenChoice.allCases.firstIndex(of: preferences.overlayScreen) ?? 0)
        delay.doubleValue = preferences.revealDelay
        privateLayer.state = preferences.usesPrivateSpaceLayer ? .on : .off
        showDelayValue()
    }

    private func buildScreens() {
        screens.addItems(withTitles: OverlayScreenChoice.allCases.map(\.label))
        screens.target = self
        screens.action = #selector(edited)
    }

    private func buildDelay() {
        delay.minValue = Preferences.delayRange.lowerBound
        delay.maxValue = Preferences.delayRange.upperBound
        delay.isContinuous = true
        delay.target = self
        delay.action = #selector(edited)
        delay.widthAnchor.constraint(equalToConstant: 200).isActive = true
        delayValue.widthAnchor.constraint(equalToConstant: 60).isActive = true
    }

    private func grid() -> NSGridView {
        let delayRow = NSStackView(views: [delay, delayValue])
        delayRow.spacing = 8
        let caption = NSTextField(wrappingLabelWithString: Self.caption)
        caption.font = .preferredFont(forTextStyle: .caption1)
        caption.textColor = .secondaryLabelColor
        caption.preferredMaxLayoutWidth = 320
        let grid = NSGridView(views: [
            [Self.label("Show the ribbon on"), screens],
            [Self.label("Reveal delay"), delayRow],
            [NSGridCell.emptyContentView, privateLayer],
            [NSGridCell.emptyContentView, caption],
        ])
        grid.column(at: 0).xPlacement = .trailing
        grid.rowSpacing = 12
        grid.columnSpacing = 12
        return grid
    }

    private func install(_ grid: NSGridView) {
        grid.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: grid.trailingAnchor, constant: 20),
            bottomAnchor.constraint(equalTo: grid.bottomAnchor, constant: 20),
        ])
    }

    @objc
    private func edited() {
        showDelayValue()
        onChange(
            Preferences(
                revealDelay: delay.doubleValue,
                overlayScreen: OverlayScreenChoice.allCases[screens.indexOfSelectedItem],
                usesPrivateSpaceLayer: privateLayer.state == .on
            )
        )
    }

    /// The label shows the value the app will actually use, not the raw slider position.
    private func showDelayValue() {
        let stored = Preferences(revealDelay: delay.doubleValue).revealDelay
        delayValue.stringValue = "\(Int((stored * 1000).rounded())) ms"
    }

    private static func label(_ title: String) -> NSTextField {
        NSTextField(labelWithString: title)
    }

    private static let caption = """
        The private layer knows which Space a minimised window belongs to, but it is \
        undocumented. Off, the app uses on-screen windows only, which is documented and \
        blind to minimised ones.
        """
}
