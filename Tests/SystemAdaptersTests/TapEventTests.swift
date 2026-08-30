import CoreGraphics
import SwitcherCore
import Testing

@testable import SystemAdapters

@Suite("Tap event")
struct TapEventTests {
    private func event(key: CGKeyCode = 48, flags: CGEventFlags = []) throws -> CGEvent {
        let event = try #require(CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true))
        event.flags = flags
        return event
    }

    @Test("both ways the system disables a tap are recognised")
    func disabledEvents() throws {
        #expect(try TapEvent(event: event(), type: .tapDisabledByTimeout) == .disabled)
        #expect(try TapEvent(event: event(), type: .tapDisabledByUserInput) == .disabled)
    }

    @Test("a key event carries its stroke")
    func keyEventCarriesStroke() throws {
        let tapEvent = try TapEvent(event: event(flags: [.maskCommand]), type: .keyDown)
        #expect(tapEvent == .stroke(KeyStroke(key: .tab, modifiers: [.command], phase: .down)))
    }

    @Test("anything else is ignored")
    func otherEventsAreIgnored() throws {
        #expect(try TapEvent(event: event(), type: .mouseMoved) == .ignored)
        #expect(try TapEvent(event: event(), type: .scrollWheel) == .ignored)
    }
}
