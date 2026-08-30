import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public struct WorkspaceApplicationActivator: ApplicationActivator {
    public init() {}

    public func activate(_ process: ProcessIdentifier) -> Bool {
        guard let application = NSRunningApplication(processIdentifier: process.rawValue) else { return false }
        return application.activate()
    }
}
