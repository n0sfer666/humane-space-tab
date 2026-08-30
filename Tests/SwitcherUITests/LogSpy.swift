import SwitcherCore
import SystemPorts

final class LogSpy: LogSink, @unchecked Sendable {
    private(set) var events: [LogEvent] = []

    func record(_ event: LogEvent) {
        events.append(event)
    }
}
