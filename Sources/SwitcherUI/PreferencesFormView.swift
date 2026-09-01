import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class PreferencesFormView: NSView {
    private let screens = NSPopUpButton()
    private let languages = NSPopUpButton()
    private let delay = NSSlider()
    private let delayValue = NSTextField(labelWithString: "")
    private let privateLayer = NSButton(
        checkboxWithTitle: Localised.text(.generalPrivateLayer),
        target: nil,
        action: nil
    )
    private let windowSwitching = NSButton(
        checkboxWithTitle: Localised.text(.generalWindowSwitching),
        target: nil,
        action: nil
    )
    private let onChange: @MainActor (Preferences) -> Void
    private var launch: LoginItemRow?
    private var shortcuts: ShortcutRows?

    init(
        preferences: Preferences,
        loginItem: LoginItem,
        formatter: ShortcutFormatter,
        recording: any ShortcutRecorderSource,
        requestGrant: @escaping @MainActor () -> Void,
        onChange: @escaping @MainActor (Preferences) -> Void
    ) {
        self.onChange = onChange
        super.init(frame: .zero)
        launch = LoginItemRow(item: loginItem) { [weak self] in
            self?.window?.setContentSize(self?.fittingSize ?? .zero)
        }
        shortcuts = ShortcutRows(
            preferences: preferences,
            formatter: formatter,
            recording: recording,
            requestGrant: requestGrant
        ) { [weak self] in
            self?.edited()
        }
        buildScreens()
        buildLanguages()
        buildDelay()
        privateLayer.target = self
        privateLayer.action = #selector(edited)
        windowSwitching.target = self
        windowSwitching.action = #selector(edited)
        install(grid())
        show(preferences)
        launch?.show()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func show(_ preferences: Preferences) {
        screens.selectItem(at: OverlayScreenChoice.allCases.firstIndex(of: preferences.overlayScreen) ?? 0)
        languages.selectItem(at: InterfaceLanguage.allCases.firstIndex(of: preferences.language) ?? 0)
        delay.doubleValue = preferences.revealDelay
        privateLayer.state = preferences.usesPrivateSpaceLayer ? .on : .off
        windowSwitching.state = preferences.switchesWindows ? .on : .off
        showDelayValue()
    }

    private func buildScreens() {
        screens.addItems(
            withTitles: OverlayScreenChoice.allCases.map { Localised.text(ScreenChoiceTitle.key(for: $0)) })
        screens.target = self
        screens.action = #selector(edited)
    }

    private func buildLanguages() {
        languages.addItems(withTitles: InterfaceLanguage.allCases.map(Self.title))
        languages.target = self
        languages.action = #selector(edited)
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
            [
                Self.label(Localised.text(.generalApplications)),
                shortcuts?.applicationsView ?? NSGridCell.emptyContentView,
            ],
            [Self.label(Localised.text(.generalFrontWindows)), shortcuts?.windowsView ?? NSGridCell.emptyContentView],
            [Self.label(Localised.text(.generalScreen)), screens],
            [Self.label(Localised.text(.generalLanguage)), languages],
            [Self.label(Localised.text(.generalRevealDelay)), delayRow],
            [NSGridCell.emptyContentView, launch?.checkbox ?? NSGridCell.emptyContentView],
            [NSGridCell.emptyContentView, launch?.note ?? NSGridCell.emptyContentView],
            [NSGridCell.emptyContentView, windowSwitching],
            [NSGridCell.emptyContentView, privateLayer],
            [NSGridCell.emptyContentView, caption],
        ])
        launch.map { row in row.noteRow = grid.cell(for: row.note)?.row }
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
                usesPrivateSpaceLayer: privateLayer.state == .on,
                switchesWindows: windowSwitching.state == .on,
                shortcut: shortcuts?.applications ?? .commandTab,
                windowShortcut: shortcuts?.windows ?? .commandGrave,
                language: InterfaceLanguage.allCases[languages.indexOfSelectedItem]
            )
        )
    }

    /// The label shows the value the app will actually use, not the raw slider position.
    private func showDelayValue() {
        let stored = Preferences(revealDelay: delay.doubleValue).revealDelay
        delayValue.stringValue = Localised.text(.unitMilliseconds, Int((stored * 1000).rounded()))
    }

    /// `.system` is a choice, not a language, so it is the one item in the list that is
    /// itself translated.
    private static func title(_ language: InterfaceLanguage) -> String {
        language == .system ? Localised.text(.generalLanguageSystem) : language.endonym
    }

    private static func label(_ title: String) -> NSTextField {
        NSTextField(labelWithString: title)
    }

    private static var caption: String { Localised.text(.generalPrivateLayerNote) }
}
