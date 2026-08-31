import AppKit
import SwitcherCore
import SystemPorts

@MainActor
final class ShortcutRecorderView: NSView {
    private var controls: ShortcutRecorderControls?
    private let formatter: ShortcutFormatter
    private let source: any ShortcutRecorderSource
    private let requestGrant: @MainActor () -> Void
    private let taken: @MainActor () -> Shortcut?
    private let willRecord: @MainActor () -> Void
    private let onChange: @MainActor (Shortcut) -> Void
    private let standard: Shortcut
    private var shortcut: Shortcut
    private(set) var isRecording = false

    init(
        shortcut: Shortcut,
        standard: Shortcut = .commandTab,
        formatter: ShortcutFormatter,
        source: any ShortcutRecorderSource,
        requestGrant: @escaping @MainActor () -> Void,
        taken: @escaping @MainActor () -> Shortcut? = { nil },
        willRecord: @escaping @MainActor () -> Void = {},
        onChange: @escaping @MainActor (Shortcut) -> Void
    ) {
        self.shortcut = shortcut
        self.standard = standard
        self.formatter = formatter
        self.source = source
        self.requestGrant = requestGrant
        self.taken = taken
        self.willRecord = willRecord
        self.onChange = onChange
        super.init(frame: .zero)
        install()
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

    private func install() {
        let controls = ShortcutRecorderControls(
            onField: { [weak self] in self?.fieldClicked() },
            onRestore: { [weak self] in self?.restoreClicked() },
            onGrant: requestGrant
        )
        self.controls = controls
        controls.translatesAutoresizingMaskIntoConstraints = false
        addSubview(controls)
        NSLayoutConstraint.activate([
            controls.topAnchor.constraint(equalTo: topAnchor),
            controls.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: controls.trailingAnchor),
            bottomAnchor.constraint(equalTo: controls.bottomAnchor),
        ])
    }

    private func fieldClicked() {
        if isRecording {
            endRecording()
        } else {
            beginRecording()
        }
    }

    private func restoreClicked() {
        adopt(standard)
        endRecording()
    }

    @objc
    private func windowResignedKey() {
        endRecording()
    }

    func beginRecording() {
        willRecord()
        guard source.start(emit: { [weak self] in self?.handle($0) }) else {
            controls?.message = Self.permissionMessage
            controls?.showsGrant = true
            return
        }
        controls?.showsGrant = false
        isRecording = true
        show()
        controls?.message = Self.hint
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
            controls?.message = ShortcutRejectionMessage.text(for: rejection)
        case .recorded(let recorded):
            if let rejection = ShortcutRule.rejection(for: recorded, taken: taken()) {
                controls?.message = ShortcutRejectionMessage.text(for: rejection)
                return
            }
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
        controls?.show(
            isRecording ? "Type a shortcut…" : formatter.label(for: shortcut),
            restoreEnabled: !isRecording && shortcut != standard
        )
        if !isRecording { controls?.message = "" }
    }

    private static let hint = "Press Escape to cancel."
    private static let permissionMessage = "Accessibility is required to record a shortcut."
}
