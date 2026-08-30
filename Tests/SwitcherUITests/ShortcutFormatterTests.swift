import SwitcherCore
import Testing

@testable import SwitcherUI

@Suite("Shortcut formatter")
@MainActor
struct ShortcutFormatterTests {
    private let formatter = ShortcutFormatter(naming: KeyNamingStub(names: [.letterQ: "Q"]))

    @Test("modifiers are printed in the order the system prints them")
    func ordersModifiers() {
        let shortcut = Shortcut(key: .tab, modifiers: [.command, .shift, .option, .control])
        #expect(formatter.label(for: shortcut) == "⌃⌥⇧⌘⇥")
    }

    @Test("the default reads the way the system writes it")
    func formatsDefault() {
        #expect(formatter.label(for: .commandTab) == "⌘⇥")
    }

    @Test("a key without a layout-independent glyph is named by the layout")
    func asksTheLayout() {
        #expect(formatter.label(for: Shortcut(key: .letterQ, modifiers: [.control])) == "⌃Q")
    }

    @Test("a key the layout cannot name is still identified")
    func namesUnknownKey() {
        #expect(formatter.label(for: Shortcut(key: .letterW, modifiers: [.option])) == "⌥Key 13")
    }
}
