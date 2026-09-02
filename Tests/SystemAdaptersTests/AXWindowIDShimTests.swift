import AppKit
import ApplicationServices
import Testing

@testable import SystemAdapters

/// The private function is only ever handed elements a trusted process was given. A process
/// without the grant — a continuous integration runner, most of all — has none to hand it, and
/// asking it anyway is undefined rather than merely fruitless, so the cases that call it do not
/// run there.
private let trusted = AXIsProcessTrusted()

@MainActor
@Suite("AX window id shim")
struct AXWindowIDShimTests {
    private static func ownWindows() -> [AXUIElement] {
        let application = AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier)
        AXUIElementSetMessagingTimeout(application, 0.5)
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(application, kAXWindowsAttribute as CFString, &value) == .success,
            let windows = value as? [AXUIElement]
        else {
            return []
        }
        return windows
    }

    @Test("the private symbol is still where this system keeps it")
    func theSymbolResolves() throws {
        _ = try #require(AXWindowIDShim())
    }

    @Test("an element that names no window is refused instead of given a made-up id", .enabled(if: trusted))
    func anElementWithNoWindowIsRefused() throws {
        let shim = try #require(AXWindowIDShim())
        let application = AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier)
        AXUIElementSetMessagingTimeout(application, 0.5)
        #expect(shim.identifier(of: application) == nil)
    }

    @Test("the id a window is given is the one the window server knows it by", .enabled(if: trusted))
    func theIdentifierIsTheWindowServersOwn() throws {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 80),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.orderFront(nil)
        defer { window.close() }
        let shim = try #require(AXWindowIDShim())
        let elements = Self.ownWindows()
        try withKnownIssue("the accessibility API answers this process nothing", isIntermittent: true) {
            let element = try #require(elements.first)
            #expect(shim.identifier(of: element)?.rawValue == UInt32(window.windowNumber))
        } when: {
            elements.isEmpty
        }
    }
}
