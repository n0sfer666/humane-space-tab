import AppKit
import SystemPorts

public final class SystemSettingsInputMonitoring: InputMonitoringSettings {
    private static let settingsURL =
        "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"

    public init() {}

    public func open() {
        guard let url = URL(string: Self.settingsURL) else { return }
        NSWorkspace.shared.open(url)
    }
}
