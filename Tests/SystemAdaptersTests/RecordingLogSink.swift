import SwitcherCore
import SystemPorts

final class RecordingLogSink: LogSink, @unchecked Sendable {
    private(set) var events: [LogEvent] = []

    func record(_ event: LogEvent) {
        events.append(event)
    }
}
