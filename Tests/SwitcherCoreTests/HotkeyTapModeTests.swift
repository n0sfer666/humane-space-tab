import Testing

@testable import SwitcherCore

@Suite("Hotkey tap mode")
struct HotkeyTapModeTests {
    @Test("observing never swallows an event")
    func observeNeverSwallows() {
        #expect(HotkeyTapMode.observe.swallows(.command(.commit)) == false)
        #expect(HotkeyTapMode.observe.swallows(.consume) == false)
        #expect(HotkeyTapMode.observe.swallows(.passThrough) == false)
    }

    @Test("intercepting swallows everything the switcher handled")
    func interceptSwallowsHandledEvents() {
        #expect(HotkeyTapMode.intercept.swallows(.command(.activate(.forward))))
        #expect(HotkeyTapMode.intercept.swallows(.consume))
        #expect(HotkeyTapMode.intercept.swallows(.passThrough) == false)
    }
}
