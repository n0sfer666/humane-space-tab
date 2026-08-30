import CoreGraphics
import SwitcherCore
import Testing

@testable import SystemAdapters

@Suite("Key stroke mapping")
struct KeyStrokeMappingTests {
    private func event(key: CGKeyCode, down: Bool = true, flags: CGEventFlags = []) throws -> CGEvent {
        let event = try #require(CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: down))
        event.flags = flags
        return event
    }

    @Test("the four switcher modifiers are carried over")
    func modifiersAreCarriedOver() {
        let flags: CGEventFlags = [.maskCommand, .maskShift, .maskControl, .maskAlternate]
        #expect(ModifierSet(eventFlags: flags) == [.command, .shift, .control, .option])
    }

    @Test("caps lock, function and the numeric pad are not modifiers here")
    func irrelevantFlagsAreIgnored() {
        let flags: CGEventFlags = [.maskCommand, .maskAlphaShift, .maskNumericPad, .maskSecondaryFn]
        #expect(ModifierSet(eventFlags: flags) == [.command])
    }

    @Test("no flags means no modifiers")
    func emptyFlags() {
        #expect(ModifierSet(eventFlags: []).isEmpty)
    }

    @Test("only keyboard event types have a phase")
    func phaseOfEventTypes() {
        #expect(KeyPhase(eventType: .keyDown) == .down)
        #expect(KeyPhase(eventType: .keyUp) == .up)
        #expect(KeyPhase(eventType: .flagsChanged) == .flagsChanged)
        #expect(KeyPhase(eventType: .tapDisabledByTimeout) == nil)
        #expect(KeyPhase(eventType: .tapDisabledByUserInput) == nil)
        #expect(KeyPhase(eventType: .mouseMoved) == nil)
    }

    @Test("a key down event becomes the matching stroke")
    func keyDownBecomesStroke() throws {
        let stroke = try KeyStroke(event: event(key: 48, flags: [.maskCommand]), type: .keyDown)
        #expect(stroke == KeyStroke(key: .tab, modifiers: [.command], phase: .down))
    }

    @Test("a non-keyboard event has no stroke")
    func nonKeyboardEventHasNoStroke() throws {
        #expect(try KeyStroke(event: event(key: 48), type: .tapDisabledByTimeout) == nil)
    }
}
