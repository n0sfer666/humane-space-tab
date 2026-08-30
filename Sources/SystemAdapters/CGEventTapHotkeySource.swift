import CoreGraphics
import SwitcherCore
import SystemPorts

@MainActor
public final class CGEventTapHotkeySource: HotkeyEngine {
    private static let eventMask: CGEventMask =
        (1 << CGEventType.keyDown.rawValue)
        | (1 << CGEventType.keyUp.rawValue)
        | (1 << CGEventType.flagsChanged.rawValue)

    private let shortcut: Shortcut
    private let mode: HotkeyTapMode
    private let log: any LogSink
    private let sessionOpen: @MainActor () -> Bool
    private let emit: @MainActor (HotkeyCommand) -> Void
    private var tap: HotkeyEventTap?

    public init(
        shortcut: Shortcut = .commandTab,
        mode: HotkeyTapMode,
        log: any LogSink,
        sessionOpen: @escaping @MainActor () -> Bool,
        emit: @escaping @MainActor (HotkeyCommand) -> Void
    ) {
        self.shortcut = shortcut
        self.mode = mode
        self.log = log
        self.sessionOpen = sessionOpen
        self.emit = emit
    }

    public func start() -> HotkeyEngineStatus {
        if let tap {
            tap.setEnabled(true)
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
        guard let tap = HotkeyEventTap(port: port) else {
            log.record(.hotkeyTapUnavailable)
            return .unavailable
        }
        self.tap = tap
        log.record(.hotkeyTapStarted)
        return .running
    }

    public func stop() {
        guard tap != nil else { return }
        tap = nil
        log.record(.hotkeyTapStopped)
    }

    fileprivate func swallows(_ event: CGEvent, of type: CGEventType) -> Bool {
        switch TapEvent(event: event, type: type) {
        case .disabled:
            tap?.setEnabled(true)
            log.record(.hotkeyTapReenabled)
            return false
        case .ignored:
            return false
        case .stroke(let stroke):
            return swallows(stroke)
        }
    }

    private func swallows(_ stroke: KeyStroke) -> Bool {
        let decision = HotkeyInterpreter.decide(stroke, shortcut: shortcut, sessionOpen: sessionOpen())
        if case .command(let command) = decision {
            log.record(LogEvent(command: command))
            emit(command)
        }
        return mode.swallows(decision)
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
