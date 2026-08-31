import ApplicationServices
import SwitcherCore

/// The windows an application itself admits to having, each under the id the window server
/// knows it by. The accessibility list is the truthful one: the window server keeps listing
/// windows a process has stopped drawing — twenty of them for one terminal with two windows
/// open — and those are not places a user can switch to.
@MainActor
enum AXWindowElements {
    /// The list is read inside the gesture (S16), so it is given the shortest patience of
    /// the three: a wedged application must cost a missing entry, never the frame. Titles
    /// arrive after the ribbon is up, and a raise happens once, on a commit that is not
    /// racing the frame — both can afford to wait longer than the list can.
    static let listTimeout: Float = 0.02
    static let titleTimeout: Float = 0.05
    static let raiseTimeout: Float = 0.1

    private static let identifiers = AXWindowIDShim()

    static var canIdentifyWindows: Bool { identifiers != nil }

    /// Only the wanted ids are asked for their subrole: that is one message per window the
    /// caller could use, instead of one per window the application happens to own.
    static func elements(
        of process: ProcessIdentifier,
        wanted: Set<WindowIdentifier>,
        timeout: Float
    ) -> [WindowIdentifier: AXUIElement] {
        guard let identifiers, !wanted.isEmpty else { return [:] }
        let application = AXUIElementCreateApplication(process.rawValue)
        AXUIElementSetMessagingTimeout(application, timeout)
        var elements: [WindowIdentifier: AXUIElement] = [:]
        for element in windows(of: application) {
            guard let identifier = identifiers.identifier(of: element), wanted.contains(identifier),
                isStandard(element)
            else {
                continue
            }
            elements[identifier] = element
        }
        return elements
    }

    private static func windows(of application: AXUIElement) -> [AXUIElement] {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(application, kAXWindowsAttribute as CFString, &value) == .success,
            let windows = value as? [AXUIElement]
        else {
            return []
        }
        return windows
    }

    /// Sheets, panels and system dialogs are windows to the accessibility API and are not
    /// entries anyone wants to `Cmd+Tab` to. Only an application that answers and names
    /// something else is refused: an element that answers nothing — it timed out, or its
    /// toolkit sets no subrole — keeps its place, because a window missing from the ribbon
    /// is a worse failure than one entry too many.
    private static func isStandard(_ element: AXUIElement) -> Bool {
        var copied: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &copied) == .success,
            let subrole = copied as? String
        else {
            return true
        }
        return subrole == kAXStandardWindowSubrole
    }
}
