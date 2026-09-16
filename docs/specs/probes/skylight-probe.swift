import CoreGraphics
import Darwin
import Foundation

typealias MainConnection = @convention(c) () -> Int32
typealias CopyDisplaySpaces = @convention(c) (Int32) -> Unmanaged<CFArray>?
typealias CopySpacesForWindows = @convention(c) (Int32, Int32, CFArray) -> Unmanaged<CFArray>?

let framework = "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight"
let allSpaceTypes: Int32 = 0x7

guard let handle = dlopen(framework, RTLD_LAZY) else {
    print("FAIL dlopen \(framework)")
    exit(1)
}
guard let mainSymbol = dlsym(handle, "SLSMainConnectionID"),
    let displaySymbol = dlsym(handle, "SLSCopyManagedDisplaySpaces"),
    let windowSymbol = dlsym(handle, "SLSCopySpacesForWindows")
else {
    print("FAIL dlsym — one of the three symbols is gone on this system")
    exit(1)
}
print("ok  all three symbols resolve")

let connection = unsafeBitCast(mainSymbol, to: MainConnection.self)()
guard connection != 0 else {
    print("FAIL SLSMainConnectionID returned 0")
    exit(1)
}
print("ok  connection id \(connection)")

let copyDisplaySpaces = unsafeBitCast(displaySymbol, to: CopyDisplaySpaces.self)
let copySpacesForWindows = unsafeBitCast(windowSymbol, to: CopySpacesForWindows.self)

guard let displays = copyDisplaySpaces(connection)?.takeRetainedValue() as? [[String: Any]] else {
    print("FAIL SLSCopyManagedDisplaySpaces did not answer as [[String: Any]] — the shape changed")
    exit(1)
}
print("ok  SLSCopyManagedDisplaySpaces returned \(displays.count) display(s)")

func currentSpace(on display: [String: Any]) -> UInt64? {
    let current = display["Current Space"]
    if let identifier = current as? NSNumber { return identifier.uint64Value }
    guard let space = current as? [String: Any], let identifier = space["ManagedSpaceID"] as? NSNumber else {
        return nil
    }
    return identifier.uint64Value
}

for (index, display) in displays.enumerated() {
    let keys = display.keys.sorted().joined(separator: ", ")
    let shape = display["Current Space"].map { String(describing: type(of: $0)) } ?? "nil"
    print("    display \(index): keys [\(keys)]")
    print("    display \(index): \"Current Space\" is \(shape) -> \(currentSpace(on: display).map(String.init) ?? "UNREADABLE")")
    if let spaces = display["Spaces"] as? [[String: Any]] {
        print("    display \(index): \(spaces.count) space(s) listed")
    }
}

let active = Set(displays.compactMap(currentSpace))
if active.isEmpty {
    print("FAIL no display yielded a current space — activeSpaces() would return nil and attribution falls back")
    exit(1)
}
print("ok  activeSpaces() = \(active.sorted())")

guard let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
    as? [[String: Any]]
else {
    print("FAIL CGWindowListCopyWindowInfo did not answer as [[String: Any]]")
    exit(1)
}
let numbers = windows.compactMap { $0[kCGWindowNumber as String] as? UInt32 }
print("ok  CGWindowListCopyWindowInfo returned \(numbers.count) on-screen window(s)")

var attributed = 0
var unreadable = 0
for window in numbers.prefix(40) {
    let query = [NSNumber(value: window)] as CFArray
    guard let spaces = copySpacesForWindows(connection, allSpaceTypes, query)?.takeRetainedValue() as? [NSNumber]
    else {
        unreadable += 1
        continue
    }
    if !spaces.isEmpty { attributed += 1 }
}
print("ok  SLSCopySpacesForWindows: \(attributed) window(s) attributed, \(unreadable) unreadable of \(min(numbers.count, 40)) probed")

if unreadable > 0 {
    print("FAIL at least one window answered in an unknown shape — spaces(of:) returns nil there")
    exit(1)
}
if attributed == 0 {
    print("FAIL no window was attributed to any space — Space filtering is dead on this system")
    exit(1)
}
print("PASS the Spaces path works on \(ProcessInfo.processInfo.operatingSystemVersionString)")
