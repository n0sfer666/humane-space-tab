import SwitcherCore
import SystemPorts

@MainActor
public final class InterceptingHotkeyEngine: HotkeyEngine {
    private let log: any LogSink
    private let make: @MainActor (HotkeyTapMode) -> any HotkeyEngine
    private var engine: (any HotkeyEngine)?

    public init(log: any LogSink, make: @escaping @MainActor (HotkeyTapMode) -> any HotkeyEngine) {
        self.log = log
        self.make = make
    }

    public func start() -> HotkeyEngineStatus {
        if let engine { return engine.start() }
        let intercepting = make(.intercept)
        if intercepting.start() == .running {
            engine = intercepting
            return .running
        }
        intercepting.stop()
        log.record(.hotkeyInterceptUnavailable)
        let observing = make(.observe)
        let status = observing.start()
        guard status == .running else {
            observing.stop()
            return status
        }
        engine = observing
        return status
    }

    public func stop() {
        engine?.stop()
        engine = nil
    }
}
