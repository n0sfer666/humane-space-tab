import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class PreferencesFormView: NSView {
    private let screens = NSPopUpButton()
    private let delay = NSSlider()
    private let delayValue = NSTextField(labelWithString: "")
    private let privateLayer = NSButton(checkboxWithTitle: "Use the private Space layer", target: nil, action: nil)
    private let windowSwitching = NSButton(
        checkboxWithTitle: "Switch between windows, not applications",
        target: nil,
        action: nil
    )
    private let launch = NSButton(checkboxWithTitle: "Open at login", target: nil, action: nil)
    private let launchNote = NSTextField(wrappingLabelWithString: "")
    private let onChange: @MainActor (Preferences) -> Void
    private var launchNoteRow: NSGridRow?
    private let loginItem: LoginItem
    private var recorder: ShortcutRecorderView?
    private var shortcut: Shortcut

    init(
        preferences: Preferences,
        loginItem: LoginItem,
        formatter: ShortcutFormatter,
        recording: any ShortcutRecorderSource,
        requestGrant: @escaping @MainActor () -> Void,
        onChange: @escaping @MainActor (Preferences) -> Void
    ) {
        self.onChange = onChange
        self.loginItem = loginItem
        shortcut = preferences.shortcut
        super.init(frame: .zero)
        recorder = ShortcutRecorderView(
            shortcut: preferences.shortcut,
            formatter: formatter,
            source: recording,
            requestGrant: requestGrant
        ) { [weak self] in
            self?.shortcut = $0
            self?.edited()
        }
        buildScreens()
        buildDelay()
        buildLaunch()
        privateLayer.target = self
        privateLayer.action = #selector(edited)
        windowSwitching.target = self
        windowSwitching.action = #selector(edited)
        install(grid())
        show(preferences)
        showLoginItem()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func show(_ preferences: Preferences) {
        screens.selectItem(at: OverlayScreenChoice.allCases.firstIndex(of: preferences.overlayScreen) ?? 0)
        delay.doubleValue = preferences.revealDelay
        privateLayer.state = preferences.usesPrivateSpaceLayer ? .on : .off
        windowSwitching.state = preferences.switchesWindows ? .on : .off
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

    private func buildLaunch() {
        launch.target = self
        launch.action = #selector(launchToggled)
        launchNote.font = .preferredFont(forTextStyle: .caption1)
        launchNote.textColor = .secondaryLabelColor
        launchNote.preferredMaxLayoutWidth = 320
    }

    /// The system, not our preferences file, decides what this checkbox shows: the user can
    /// revoke a login item in System Settings without ever opening this window.
    @objc
    private func launchToggled() {
        loginItem.set(launch.state == .on)
        showLoginItem()
    }

    private func showLoginItem() {
        let status = loginItem.status
        launch.state = status.isOn ? .on : .off
        launch.isEnabled = status.isEditable
        launchNote.stringValue = status.message ?? ""
        launchNoteRow?.isHidden = status.message == nil
        window?.setContentSize(fittingSize)
    }

    private func grid() -> NSGridView {
        let delayRow = NSStackView(views: [delay, delayValue])
        delayRow.spacing = 8
        let caption = NSTextField(wrappingLabelWithString: Self.caption)
        caption.font = .preferredFont(forTextStyle: .caption1)
        caption.textColor = .secondaryLabelColor
        caption.preferredMaxLayoutWidth = 320
        let grid = NSGridView(views: [
            [Self.label("Shortcut"), recorder ?? NSGridCell.emptyContentView],
            [Self.label("Show the ribbon on"), screens],
            [Self.label("Reveal delay"), delayRow],
            [NSGridCell.emptyContentView, launch],
            [NSGridCell.emptyContentView, launchNote],
            [NSGridCell.emptyContentView, windowSwitching],
            [NSGridCell.emptyContentView, privateLayer],
            [NSGridCell.emptyContentView, caption],
        ])
        launchNoteRow = grid.cell(for: launchNote)?.row
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
                shortcut: shortcut
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
