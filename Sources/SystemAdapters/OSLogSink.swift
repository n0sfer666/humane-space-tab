import SwitcherCore
import SystemPorts
import os

public struct OSLogSink: LogSink {
    public static let subsystem = "io.github.n0sfer666.humane-space-tab"

    private let loggers: [LogCategory: Logger]

    public init() {
        loggers = Dictionary(
            uniqueKeysWithValues: LogCategory.allCases.map {
                ($0, Logger(subsystem: Self.subsystem, category: $0.rawValue))
            }
        )
    }

    public func record(_ event: LogEvent) {
        loggers[event.category]?.log("\(event.message, privacy: .public)")
    }
}
