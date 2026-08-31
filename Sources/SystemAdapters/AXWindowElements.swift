import ApplicationServices
import CoreGraphics
import Foundation
import SwitcherCore

/// Finds the accessibility element behind a window the window server named. Every call sets
/// a short messaging timeout first: the reply comes from another application, and a wedged
/// one must cost a missing title, never a stalled gesture.
@MainActor
enum AXWindowElements {
    static let timeout: Float = 0.05

    static func elements(
        of process: ProcessIdentifier,
        windows: [WindowIdentifier]
    ) -> [WindowIdentifier: AXUIElement] {
        let wanted = Set(windows)
        let frames = frames(of: wanted)
        guard !frames.isEmpty else { return [:] }
        let application = AXUIElementCreateApplication(process.rawValue)
        AXUIElementSetMessagingTimeout(application, timeout)
        let elements = self.windows(of: application).compactMap { element in
            frame(of: element).map { (element: element, frame: $0) }
        }
        return WindowFrameMatch.pair(windows: frames, elements: elements)
    }

    private static func frames(of windows: Set<WindowIdentifier>) -> [(id: WindowIdentifier, frame: CGRect)] {
        let options: CGWindowListOption = [.optionAll, .excludeDesktopElements]
        guard let entries = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }
        return entries.compactMap { entry in
            guard let number = entry[kCGWindowNumber as String] as? UInt32,
                case let id = WindowIdentifier(rawValue: number), windows.contains(id),
                let bounds = entry[kCGWindowBounds as String] as? NSDictionary,
                let frame = CGRect(dictionaryRepresentation: bounds)
            else {
                return nil
            }
            return (id, frame)
        }
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

    private static func frame(of element: AXUIElement) -> CGRect? {
        guard let origin = point(kAXPositionAttribute, of: element),
            let size = size(kAXSizeAttribute, of: element)
        else {
            return nil
        }
        return CGRect(origin: origin, size: size)
    }

    private static func point(_ attribute: String, of element: AXUIElement) -> CGPoint? {
        var point = CGPoint.zero
        guard let value = value(attribute, of: element),
            AXValueGetValue(value, .cgPoint, &point)
        else {
            return nil
        }
        return point
    }

    private static func size(_ attribute: String, of element: AXUIElement) -> CGSize? {
        var size = CGSize.zero
        guard let value = value(attribute, of: element),
            AXValueGetValue(value, .cgSize, &size)
        else {
            return nil
        }
        return size
    }

    /// The attribute comes back as an untyped `CFTypeRef`, and Swift offers no checked cast
    /// to a Core Foundation type: the type identifier is compared first, which is exactly
    /// what such a cast would do, and the reinterpretation below cannot then be wrong.
    private static func value(_ attribute: String, of element: AXUIElement) -> AXValue? {
        var copied: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &copied) == .success,
            let copied, CFGetTypeID(copied) == AXValueGetTypeID()
        else {
            return nil
        }
        return unsafeDowncast(copied, to: AXValue.self)
    }
}
