import ApplicationServices
import SwitcherCore
import SystemPorts

/// Raises one window: un-minimise first, because a raise lands nowhere on a window in the
/// Dock, then bring it to the front of its own application. Giving the application the
/// focus stays S06's job and happens after this.
@MainActor
public struct AXWindowRaiser: WindowRaiser {
    public init() {}

    public func raise(_ window: WindowIdentifier, of process: ProcessIdentifier) -> Bool {
        guard let element = AXWindowElements.elements(of: process, windows: [window])[window] else {
            return false
        }
        unminimise(element)
        return AXUIElementPerformAction(element, kAXRaiseAction as CFString) == .success
    }

    private func unminimise(_ element: AXUIElement) {
        var copied: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXMinimizedAttribute as CFString, &copied) == .success,
            let minimised = copied as? Bool, minimised
        else {
            return
        }
        AXUIElementSetAttributeValue(element, kAXMinimizedAttribute as CFString, false as CFBoolean)
    }
}
