import CoreGraphics
import SwitcherCore
import SystemPorts

@MainActor
public struct CoreGraphicsWindowSource: WindowSource {
    public init() {}

    public func windows() -> [WindowInfo] {
        list([.optionAll, .excludeDesktopElements])
    }

    public func onScreenWindows() -> [WindowInfo] {
        list([.optionOnScreenOnly, .excludeDesktopElements])
    }

    private func list(_ options: CGWindowListOption) -> [WindowInfo] {
        guard let entries = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }
        return entries.compactMap(Self.windowInfo)
    }

    private static func windowInfo(from entry: [String: Any]) -> WindowInfo? {
        guard let number = entry[kCGWindowNumber as String] as? UInt32,
            let owner = entry[kCGWindowOwnerPID as String] as? Int32,
            let layer = entry[kCGWindowLayer as String] as? Int
        else {
            return nil
        }
        return WindowInfo(
            id: WindowIdentifier(rawValue: number),
            owner: ProcessIdentifier(rawValue: owner),
            layer: layer,
            alpha: entry[kCGWindowAlpha as String] as? Double ?? 1,
            isOnScreen: entry[kCGWindowIsOnscreen as String] as? Bool ?? false
        )
    }
}
