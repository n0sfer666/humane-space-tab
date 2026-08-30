import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class ShortcutRecorderView: NSView {
    private let field = NSButton(title: "", target: nil, action: nil)
    private let restore = NSButton(title: "Restore default", target: nil, action: nil)
    private let grant = NSButton(title: "Grant Accessibility…", target: nil, action: nil)
    private let reason = NSTextField(wrappingLabelWithString: "")
    private let formatter: ShortcutFormatter
    private let source: any ShortcutRecorderSource
    private let requestGrant: @MainActor () -> Void
    private let onChange: @MainActor (Shortcut) -> Void
    private var shortcut: Shortcut
    private(set) var isRecording = false

    init(
        shortcut: Shortcut,
        formatter: ShortcutFormatter,
        source: any ShortcutRecorderSource,
        requestGrant: @escaping @MainActor () -> Void,
        onChange: @escaping @MainActor (Shortcut) -> Void
    ) {
        self.shortcut = shortcut
        self.formatter = formatter
        self.source = source
        self.requestGrant = requestGrant
        self.onChange = onChange
        super.init(frame: .zero)
        build()
        show()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    deinit { NotificationCenter.default.removeObserver(self) }

    /// The subscription is rebuilt on every move because the notification is matched on the
    /// window object: registered while there is none it would fire for every window in the
    /// process, and a status-item menu closing would silently end the recording.
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.removeObserver(
            self,
            name: NSWindow.didResignKeyNotification,
            object: nil
        )
        guard let window else {
            endRecording()
            return
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowResignedKey),
            name: NSWindow.didResignKeyNotification,
            object: window
        )
    }

    private func build() {
        field.target = self
        field.action = #selector(fieldClicked)
        field.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        restore.target = self
        restore.action = #selector(restoreClicked)
        grant.target = self
        grant.action = #selector(grantClicked)
        grant.isHidden = true
        reason.font = .preferredFont(forTextStyle: .caption1)
        reason.textColor = .secondaryLabelColor
        reason.preferredMaxLayoutWidth = 320
        install()
    }

    private func install() {
        let row = NSStackView(views: [field, restore, grant])
        row.spacing = 8
        let column = NSStackView(views: [row, reason])
        column.orientation = .vertical
        column.alignment = .leading
        column.spacing = 4
        column.translatesAutoresizingMaskIntoConstraints = false
        addSubview(column)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: topAnchor),
            column.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: column.trailingAnchor),
            bottomAnchor.constraint(equalTo: column.bottomAnchor),
        ])
    }

    @objc
    private func fieldClicked() {
        if isRecording {
            endRecording()
        } else {
            beginRecording()
        }
    }

    @objc
    private func restoreClicked() {
        adopt(.commandTab)
        endRecording()
    }

    @objc
    private func grantClicked() {
        requestGrant()
    }

    @objc
    private func windowResignedKey() {
        endRecording()
    }

    func beginRecording() {
        guard source.start(emit: { [weak self] in self?.handle($0) }) else {
            reason.stringValue = Self.permissionMessage
            grant.isHidden = false
            return
        }
        grant.isHidden = true
        isRecording = true
        show()
        reason.stringValue = Self.hint
    }

    func endRecording() {
        guard isRecording else { return }
        isRecording = false
        source.stop()
        show()
    }

    /// A rejection keeps the recorder listening and its reason on screen until the next
    /// press: dropping out of the mode would make the user click again to be told why.
    private func handle(_ outcome: ShortcutRecordingOutcome) {
        switch outcome {
        case .incomplete:
            break
        case .cancelled:
            endRecording()
        case .rejected(let rejection):
            reason.stringValue = ShortcutRejectionMessage.text(for: rejection)
        case .recorded(let recorded):
            adopt(recorded)
            endRecording()
        }
    }

    /// Adopting before ending is what keeps the switcher's tap built once: the tap is still
    /// suspended here, so the new shortcut is in place by the time it comes back.
    private func adopt(_ recorded: Shortcut) {
        guard recorded != shortcut else { return }
        shortcut = recorded
        show()
        onChange(recorded)
    }

    private func show() {
        field.title = isRecording ? "Type a shortcut…" : formatter.label(for: shortcut)
        restore.isEnabled = !isRecording && shortcut != .commandTab
        if !isRecording { reason.stringValue = "" }
    }

    private static let hint = "Press Escape to cancel."
    private static let permissionMessage = "Accessibility is required to record a shortcut."
}
