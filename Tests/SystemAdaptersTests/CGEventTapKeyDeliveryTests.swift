import CoreGraphics
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Event tap key delivery")
struct CGEventTapKeyDeliveryTests {
    private static let keyDown = CGEventMask(1 << CGEventType.keyDown.rawValue)
    private static let keyUp = CGEventMask(1 << CGEventType.keyUp.rawValue)
    private static let flags = CGEventMask(1 << CGEventType.flagsChanged.rawValue)

    @Test("the mask macOS leaves behind when it withholds key presses is not delivery")
    func modifiersOnly() {
        #expect(CGEventTapKeyDelivery.carriesKeys(Self.flags) == false)
    }

    @Test("half the key bits is not delivery either")
    func onlyKeyDown() {
        #expect(CGEventTapKeyDelivery.carriesKeys(Self.flags | Self.keyDown) == false)
    }

    @Test("the mask the app asks for delivers")
    func bothKeyBits() {
        #expect(CGEventTapKeyDelivery.carriesKeys(Self.flags | Self.keyDown | Self.keyUp))
    }

    @Test("a process with no tap of its own reports no delivery")
    func noTapForThisProcess() {
        #expect(CGEventTapKeyDelivery(pid: -1).deliversKeyEvents == false)
    }
}
