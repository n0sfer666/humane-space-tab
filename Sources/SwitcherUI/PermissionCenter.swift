import SwitcherCore
import SystemPorts

@MainActor
public final class PermissionCenter {
    private let authority: any AccessibilityAuthority
    private let engine: any HotkeyEngine
    private let log: any LogSink
    private let poll: @MainActor (@escaping @MainActor () -> Void) -> Void
    private var observers: [@MainActor (PermissionState) -> Void] = []
    private var asked = false

    public private(set) var state: PermissionState = .blocked(canAsk: true)

    public init(
        authority: any AccessibilityAuthority,
        engine: any HotkeyEngine,
        log: any LogSink,
        poll: @escaping @MainActor (@escaping @MainActor () -> Void) -> Void
    ) {
        self.authority = authority
        self.engine = engine
        self.log = log
        self.poll = poll
    }

    public func observe(_ observer: @escaping @MainActor (PermissionState) -> Void) {
        observers.append(observer)
        observer(state)
    }

    public func start() {
        _ = engine.start()
        publish()
    }

    /// Called when the app becomes active: a permission revoked in System Settings shows up
    /// nowhere else, and a permission granted there deserves a working tap without a relaunch.
    /// A tap kept alive without the permission behind it is the one thing worse than no tap,
    /// so it is dropped and rebuilt when the permission comes back.
    public func refresh() {
        if authority.isTrusted {
            if engine.tap != .intercept {
                engine.stop()
                _ = engine.start()
            }
        } else if engine.tap != nil {
            engine.stop()
        }
        publish()
    }

    public func requestGrant() {
        if asked {
            authority.openSystemSettings()
        } else {
            asked = true
            authority.promptForTrust()
        }
        log.record(.accessibilityRequested)
    }

    private func publish() {
        let next = PermissionState(isTrusted: authority.isTrusted, tap: engine.tap)
        if next != state {
            state = next
            for observer in observers { observer(next) }
            log.record(LogEvent(permission: next))
        }
        armPollIfBlocked()
    }

    /// The timer exists only while the permission is missing: an observing tap is caused by
    /// secure input, and rebuilding it every two seconds would cost open sessions for nothing.
    private func armPollIfBlocked() {
        guard !authority.isTrusted else { return }
        poll { [weak self] in self?.refresh() }
    }
}
