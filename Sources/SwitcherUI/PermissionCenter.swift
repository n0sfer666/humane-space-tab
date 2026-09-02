import SwitcherCore
import SystemPorts

@MainActor
public final class PermissionCenter {
    private let authority: any AccessibilityAuthority
    private let engine: any HotkeyEngine
    private let delivery: any KeyEventDelivery
    private let secureInput: any SecureInputMonitor
    private let log: any LogSink
    private let now: @MainActor () -> Double
    private let poll: @MainActor (@escaping @MainActor () -> Void) -> Void
    private var observers: [@MainActor (PermissionState) -> Void] = []
    private var watch = SecureInputWatch()
    private var asked = false
    private var isSuspended = false
    private var isPolling = false

    public private(set) var state: PermissionState = .blocked(canAsk: true)

    public init(
        authority: any AccessibilityAuthority,
        engine: any HotkeyEngine,
        delivery: any KeyEventDelivery,
        secureInput: any SecureInputMonitor,
        log: any LogSink,
        now: @escaping @MainActor () -> Double,
        poll: @escaping @MainActor (@escaping @MainActor () -> Void) -> Void
    ) {
        self.authority = authority
        self.engine = engine
        self.delivery = delivery
        self.secureInput = secureInput
        self.log = log
        self.now = now
        self.poll = poll
    }

    public func observe(_ observer: @escaping @MainActor (PermissionState) -> Void) {
        observers.append(observer)
        observer(state)
    }

    public func start() {
        _ = engine.start()
        sample()
        publish()
        armPoll()
    }

    /// Called when the app becomes active: a permission revoked in System Settings shows up
    /// nowhere else, and a permission granted there deserves a working tap without a relaunch.
    /// A tap kept alive without the permission behind it is the one thing worse than no tap,
    /// so it is dropped and rebuilt when the permission comes back. A deaf tap is rebuilt for
    /// the same reason: its mask is decided at creation, so a fixed Input Monitoring row
    /// reaches the switcher only through a new tap.
    public func refresh() {
        guard !isSuspended else { return }
        if authority.isTrusted {
            if engine.tap != .intercept || !delivery.deliversKeyEvents {
                engine.stop()
                _ = engine.start()
            }
        } else if engine.tap != nil {
            engine.stop()
        }
        publish()
    }

    /// The shortcut is baked into the tap when it is built, so a new one means a new tap.
    /// A suspended tap needs none: the one that resumes is built from the current shortcut.
    public func rebuildTap() {
        guard !isSuspended else { return }
        engine.stop()
        _ = engine.start()
        publish()
    }

    /// A menu bar item is easy to miss, and the app does nothing at all until the permission
    /// is there: the first launch without it asks by itself rather than waiting to be found.
    public func requestGrantIfMissing() {
        guard !authority.isTrusted else { return }
        requestGrant()
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
        let next = PermissionState(
            isTrusted: authority.isTrusted,
            tap: engine.tap,
            deliversKeys: delivery.deliversKeyEvents,
            secureInput: watch.settled
        )
        if next != state {
            state = next
            for observer in observers { observer(next) }
            log.record(LogEvent(permission: next))
        }
    }

    private func sample() {
        watch.observe(secureInput.holder, at: now())
    }

    /// The timer runs for as long as the app does, because the two things it watches are
    /// both invisible from anywhere else: a permission granted in System Settings, and
    /// secure input, which macOS starts and ends without telling anyone. It rebuilds
    /// nothing — a deaf tap rebuilt every two seconds would cost open sessions for
    /// nothing — so once there is a tap the tick only looks and reports.
    private func armPoll() {
        guard !isPolling else { return }
        isPolling = true
        poll { [weak self] in self?.tick() }
    }

    private func tick() {
        isPolling = false
        defer { armPoll() }
        guard !isSuspended else { return }
        sample()
        if authority.isTrusted, hasTap {
            publish()
        } else {
            refresh()
        }
    }

    private var hasTap: Bool {
        if case .blocked = state { false } else { true }
    }
}

/// While the tap is suspended nothing else may put it back — not the activation refresh,
/// not the timer that polls for a granted permission, not a changed shortcut. The published
/// state is left as it was, because a tap the user deliberately stood down is not a
/// permission problem to report.
extension PermissionCenter: TapSuspending {
    public func suspend() {
        guard !isSuspended else { return }
        isSuspended = true
        engine.stop()
    }

    public func resume() {
        guard isSuspended else { return }
        isSuspended = false
        _ = engine.start()
        publish()
    }
}
