import CoreGraphics
import SwitcherCore
import SystemPorts

@MainActor
public final class CGEventTapHotkeySource: HotkeyEngine {
    private static let eventMask: CGEventMask =
        (1 << CGEventType.keyDown.rawValue)
        | (1 << CGEventType.keyUp.rawValue)
        | (1 << CGEventType.flagsChanged.rawValue)

    private let shortcuts: ShortcutSet
    private let mode: HotkeyTapMode
    private let log: any LogSink
    private let session: @MainActor () -> SwitcherScope?
    private let emit: @MainActor (HotkeyCommand) -> Void
    private var port: HotkeyEventTap?
    private var swallowing: SwallowPolicy

    public var tap: HotkeyTapMode? { port == nil ? nil : mode }

    public init(
        shortcuts: ShortcutSet,
        mode: HotkeyTapMode,
        log: any LogSink,
        session: @escaping @MainActor () -> SwitcherScope?,
        emit: @escaping @MainActor (HotkeyCommand) -> Void
    ) {
        self.shortcuts = shortcuts
        self.mode = mode
        self.log = log
        self.session = session
        self.emit = emit
        swallowing = SwallowPolicy(mode: mode)
    }

    public func start() -> HotkeyEngineStatus {
        if let port {
            port.setEnabled(true)
            return .running
        }
        let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: mode == .intercept ? .defaultTap : .listenOnly,
            eventsOfInterest: Self.eventMask,
            callback: hotkeyTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        guard let created = HotkeyEventTap(port: port) else {
            log.record(.hotkeyTapUnavailable)
            return .unavailable
        }
        self.port = created
        log.record(.hotkeyTapStarted)
        return .running
    }

    public func stop() {
        guard port != nil else { return }
        port = nil
        log.record(.hotkeyTapStopped)
    }

    fileprivate func swallows(_ event: CGEvent, of type: CGEventType) -> Bool {
        swallows(TapEvent(event: event, type: type))
    }

    func swallows(_ event: TapEvent) -> Bool {
        switch event {
        case .disabled:
            port?.setEnabled(true)
            swallowing = SwallowPolicy(mode: mode)
            log.record(.hotkeyTapReenabled)
            recoverSession()
            return false
        case .ignored:
            return false
        case .stroke(let stroke):
            return swallows(stroke)
        }
    }

    private func recoverSession() {
        guard session() != nil else { return }
        log.record(LogEvent(command: .cancel))
        emit(.cancel)
    }

    /// An activation that opened nothing is not ours to keep: the key belongs to whatever
    /// is in front, and treating it as a pass-through is also what keeps the swallow policy
    /// honest — a press nobody swallowed leaves no unpaired release behind it.
    private func swallows(_ stroke: KeyStroke) -> Bool {
        var decision = HotkeyInterpreter.decide(stroke, shortcuts: shortcuts, session: session())
        if case .command(let command) = decision {
            log.record(LogEvent(command: command))
            emit(command)
            if case .activate = command, session() == nil { decision = .passThrough }
        }
        return swallowing.swallows(decision, of: stroke)
    }
}

private func hotkeyTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passUnretained(event) }
    let source = Unmanaged<CGEventTapHotkeySource>.fromOpaque(userInfo).takeUnretainedValue()
    nonisolated(unsafe) let stroke = event
    let swallowed = MainActor.assumeIsolated { source.swallows(stroke, of: type) }
    return swallowed ? nil : Unmanaged.passUnretained(event)
}
