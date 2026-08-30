import CoreGraphics
import Darwin
import Foundation

struct SkyLightShim {
    private typealias MainConnection = @convention(c) () -> Int32
    private typealias CopyDisplaySpaces = @convention(c) (Int32) -> Unmanaged<CFArray>?
    private typealias CopySpacesForWindows = @convention(c) (Int32, Int32, CFArray) -> Unmanaged<CFArray>?

    private static let framework = "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight"
    private static let allSpaceTypes: Int32 = 0x7

    private let connection: Int32
    private let copyDisplaySpaces: CopyDisplaySpaces
    private let copySpacesForWindows: CopySpacesForWindows

    init?() {
        guard let handle = dlopen(Self.framework, RTLD_LAZY) else { return nil }
        guard let mainConnection = dlsym(handle, "SLSMainConnectionID"),
            let displaySpaces = dlsym(handle, "SLSCopyManagedDisplaySpaces"),
            let windowSpaces = dlsym(handle, "SLSCopySpacesForWindows")
        else {
            dlclose(handle)
            return nil
        }
        connection = unsafeBitCast(mainConnection, to: MainConnection.self)()
        copyDisplaySpaces = unsafeBitCast(displaySpaces, to: CopyDisplaySpaces.self)
        copySpacesForWindows = unsafeBitCast(windowSpaces, to: CopySpacesForWindows.self)
        guard connection != 0 else { return nil }
    }

    /// The current Space of every display, or `nil` when the answer has a shape we do not know.
    func activeSpaces() -> Set<UInt64>? {
        guard let displays = copyDisplaySpaces(connection)?.takeRetainedValue() as? [[String: Any]] else {
            return nil
        }
        let spaces = Set(displays.compactMap(Self.currentSpace))
        return spaces.isEmpty ? nil : spaces
    }

    /// The Spaces a window belongs to, or `nil` when the call fails or answers in an unknown shape.
    func spaces(of window: UInt32) -> Set<UInt64>? {
        let query = [NSNumber(value: window)] as CFArray
        guard
            let spaces = copySpacesForWindows(connection, Self.allSpaceTypes, query)?
                .takeRetainedValue() as? [NSNumber]
        else {
            return nil
        }
        return Set(spaces.map(\.uint64Value))
    }

    static func currentSpace(on display: [String: Any]) -> UInt64? {
        let current = display["Current Space"]
        if let identifier = current as? NSNumber { return identifier.uint64Value }
        guard let space = current as? [String: Any],
            let identifier = space["ManagedSpaceID"] as? NSNumber
        else {
            return nil
        }
        return identifier.uint64Value
    }
}
