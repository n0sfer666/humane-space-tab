import AppKit
import ApplicationServices
import SystemPorts

@MainActor
public final class AXAccessibilityAuthority: AccessibilityAuthority {
    private static let settingsURL =
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

    public init() {}

    public var isTrusted: Bool { AXIsProcessTrusted() }

    /// The key is spelled out because the framework exposes its constant as a mutable
    /// global, which Swift 6 refuses to read from an isolated context; the value is fixed
    /// API. The bridge to `CFDictionary` is the only call shape this function accepts.
    public func promptForTrust() {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    public func openSystemSettings() {
        guard let url = URL(string: Self.settingsURL) else { return }
        NSWorkspace.shared.open(url)
    }
}
