import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public final class WorkspaceApplicationIconSource: ApplicationIconSource {
    public init() {}

    public func icon(for process: ProcessIdentifier) -> NSImage? {
        NSRunningApplication(processIdentifier: process.rawValue)?.icon
    }

    public func prewarm(_ processes: [ProcessIdentifier]) {
        for process in processes { _ = icon(for: process) }
    }
}
