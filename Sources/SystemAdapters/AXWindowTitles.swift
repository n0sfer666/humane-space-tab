import ApplicationServices
import SwitcherCore
import SystemPorts

/// Reads window titles over the accessibility API — the grant the app already holds for
/// interception, and not the Screen Recording the window server's own title would need. A
/// title is drawn and discarded with the session: nothing here logs one or writes one down.
@MainActor
public struct AXWindowTitles: WindowTitleSource {
    public init() {}

    public func titles(
        of process: ProcessIdentifier,
        windows: [WindowIdentifier]
    ) -> [WindowIdentifier: String] {
        AXWindowElements.elements(of: process, windows: windows)
            .compactMapValues(Self.title)
    }

    private static func title(of element: AXUIElement) -> String? {
        var copied: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &copied) == .success,
            let title = copied as? String, !title.isEmpty
        else {
            return nil
        }
        return title
    }
}
