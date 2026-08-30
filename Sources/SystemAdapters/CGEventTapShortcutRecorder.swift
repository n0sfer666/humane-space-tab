import CoreGraphics
import Dispatch
import SwitcherCore
import SystemPorts

@MainActor
public final class CGEventTapShortcutRecorder: ShortcutRecorderSource {
    private static let eventMask: CGEventMask =
        (1 << CGEventType.keyDown.rawValue)
        | (1 << CGEventType.keyUp.rawValue)
        | (1 << CGEventType.flagsChanged.rawValue)

    private let schedule: @MainActor (@escaping @MainActor () -> Void) -> Void
    private var port: HotkeyEventTap?
    private var emit: (@MainActor (ShortcutRecordingOutcome) -> Void)?
    private var swallowedDowns: Set<KeyCode> = []
    private var finished: ShortcutRecordingOutcome?

    public init(
        schedule: @escaping @MainActor (@escaping @MainActor () -> Void) -> Void = { work in
            DispatchQueue.main.async { MainActor.assumeIsolated(work) }
        }
    ) {
        self.schedule = schedule
    }

    /// The tap has to sit ahead of the window server, because macOS handles its own
    /// `Cmd+Tab` before any application sees it — a recorder built on ordinary key events
    /// could never record the one combination this app exists to take over.
    public func start(emit: @escaping @MainActor (ShortcutRecordingOutcome) -> Void) -> Bool {
        self.emit = emit
        swallowedDowns = []
        finished = nil
        if let port {
            port.setEnabled(true)
            return true
        }
        let created = HotkeyEventTap(
            port: CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: Self.eventMask,
                callback: shortcutRecorderTapCallback,
                userInfo: Unmanaged.passUnretained(self).toOpaque()
            )
        )
        guard let created else {
            self.emit = nil
            return false
        }
        port = created
        return true
    }

    public func stop() {
        port = nil
        emit = nil
        swallowedDowns = []
        finished = nil
    }

    func swallows(_ event: TapEvent) -> Bool {
        switch event {
        case .disabled:
            port?.setEnabled(true)
            swallowedDowns = []
            deliverIfFinished()
            return false
        case .ignored:
            return false
        case .stroke(let stroke):
            return swallows(stroke)
        }
    }

    /// Modifier changes are reported but not swallowed: a modifier the system never sees
    /// released leaves every other application believing it is still held. A press is kept
    /// until its own release has been swallowed too, so the key the user typed cannot leak
    /// out half-way as an unpaired release.
    private func swallows(_ stroke: KeyStroke) -> Bool {
        switch stroke.phase {
        case .flagsChanged:
            if finished == nil { emit?(.incomplete) }
            return false
        case .down:
            swallowedDowns.insert(stroke.key)
            guard finished == nil else { return true }
            record(ShortcutRecording.outcome(key: stroke.key, modifiers: stroke.modifiers))
            return true
        case .up:
            guard swallowedDowns.remove(stroke.key) != nil else { return false }
            deliverIfFinished()
            return true
        }
    }

    private func record(_ outcome: ShortcutRecordingOutcome) {
        switch outcome {
        case .recorded, .cancelled:
            finished = outcome
        case .incomplete, .rejected:
            emit?(outcome)
        }
    }

    /// Delivering the outcome tears this tap down and rebuilds the switcher's own, and
    /// neither may happen inside the callout the window server is synchronously waiting on.
    private func deliverIfFinished() {
        guard let outcome = finished, let emit else { return }
        finished = nil
        schedule { emit(outcome) }
    }
}

private func shortcutRecorderTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passUnretained(event) }
    let recorder = Unmanaged<CGEventTapShortcutRecorder>.fromOpaque(userInfo).takeUnretainedValue()
    nonisolated(unsafe) let captured = event
    let swallowed = MainActor.assumeIsolated { recorder.swallows(TapEvent(event: captured, type: type)) }
    return swallowed ? nil : Unmanaged.passUnretained(event)
}
