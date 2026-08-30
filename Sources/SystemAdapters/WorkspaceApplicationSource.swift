import AppKit
import SwitcherCore
import SystemPorts

@MainActor
public struct WorkspaceApplicationSource: ApplicationSource {
    public init() {}

    public func runningApplications() -> [RunningApplication] {
        NSWorkspace.shared.runningApplications.map { application in
            RunningApplication(
                pid: ProcessIdentifier(rawValue: application.processIdentifier),
                bundleIdentifier: application.bundleIdentifier,
                name: application.localizedName ?? application.bundleIdentifier ?? "",
                bundlePath: application.bundleURL?.path,
                policy: Self.policy(of: application.activationPolicy),
                isHidden: application.isHidden,
                isActive: application.isActive
            )
        }
    }

    private static func policy(of policy: NSApplication.ActivationPolicy) -> ActivationPolicy {
        switch policy {
        case .regular: .regular
        case .accessory: .accessory
        case .prohibited: .prohibited
        @unknown default: .prohibited
        }
    }
}
