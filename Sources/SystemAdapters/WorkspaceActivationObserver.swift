import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public final class WorkspaceActivationObserver: ApplicationActivationObserver {
    nonisolated(unsafe) private var token: (any NSObjectProtocol)?

    public init() {}

    public func observe(_ handler: @escaping @MainActor (ProcessIdentifier) -> Void) {
        stop()
        token = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard
                let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                    as? NSRunningApplication
            else { return }
            MainActor.assumeIsolated { handler(ProcessIdentifier(rawValue: application.processIdentifier)) }
        }
    }

    public func stop() {
        guard let token else { return }
        NSWorkspace.shared.notificationCenter.removeObserver(token)
        self.token = nil
    }

    deinit {
        guard let token else { return }
        NSWorkspace.shared.notificationCenter.removeObserver(token)
    }
}
