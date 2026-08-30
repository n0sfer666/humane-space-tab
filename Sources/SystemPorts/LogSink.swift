import SwitcherCore

public protocol LogSink: Sendable {
    func record(_ event: LogEvent)
}
