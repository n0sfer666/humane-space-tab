import AppKit
import ApplicationServices
import Testing

@testable import SystemAdapters

@MainActor
@Suite("AX window id shim")
struct AXWindowIDShimTests {
    /// A process the accessibility API refuses answers nothing, and the whole point of this
    /// suite is what the answer is — so the cases that need one say when they cannot run
    /// instead of failing for the wrong reason.
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

    @Test("an element that names no window is refused instead of given a made-up id")
    func anElementWithNoWindowIsRefused() throws {
        let shim = try #require(AXWindowIDShim())
        let application = AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier)
        AXUIElementSetMessagingTimeout(application, 0.5)
        #expect(shim.identifier(of: application) == nil)
    }

    /// The window is left open on purpose. Closing it takes a headless session's test process
    /// down with a signal — a runner has a window server that hands out a window and cannot
    /// take it back — and a process about to exit has nothing to gain by tidying it away.
    @Test("the id a window is given is the one the window server knows it by")
    func theIdentifierIsTheWindowServersOwn() throws {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 80),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.orderFront(nil)
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
