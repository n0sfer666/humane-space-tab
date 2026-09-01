import AppKit
import SwitcherCore

/// The status item is the only proof the app is running, so it never renders empty: a symbol
/// the running system does not know falls back to a glyph the menu bar can always draw.
enum MenuBarIcon {
    static let fallback = "⇄"

    static func symbol(for state: PermissionState) -> String {
        state.needsAttention ? "exclamationmark.triangle" : "arrow.left.arrow.right"
    }

    @MainActor
    static func image(for state: PermissionState) -> NSImage? {
        NSImage(systemSymbolName: symbol(for: state), accessibilityDescription: Localised.text(.appName))
    }
}
