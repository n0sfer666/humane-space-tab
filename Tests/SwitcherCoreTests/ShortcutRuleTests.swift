import Testing

@testable import SwitcherCore

@Suite("Shortcut rule")
struct ShortcutRuleTests {
    @Test("a shortcut with a held modifier and an ordinary key is accepted")
    func acceptsHeldModifier() {
        #expect(ShortcutRule.rejection(for: Shortcut(key: .tab, modifiers: [.option])) == nil)
        #expect(ShortcutRule.rejection(for: .commandTab) == nil)
        #expect(ShortcutRule.rejection(for: Shortcut(key: .space, modifiers: [.control, .option])) == nil)
    }

    @Test("a shortcut with nothing to hold is refused")
    func refusesModifierless() {
        #expect(ShortcutRule.rejection(for: Shortcut(key: .tab, modifiers: [])) == .noModifier)
        #expect(ShortcutRule.rejection(for: Shortcut(key: .space, modifiers: [])) == .noModifier)
    }

    @Test("a shortcut that already contains Shift has no backward direction")
    func refusesShift() {
        #expect(ShortcutRule.rejection(for: Shortcut(key: .tab, modifiers: [.command, .shift])) == .containsShift)
        #expect(ShortcutRule.rejection(for: Shortcut(key: .tab, modifiers: [.shift])) == .containsShift)
    }

    @Test("Escape stays the way out of a session and of a wedged application")
    func refusesEscape() {
        #expect(ShortcutRule.rejection(for: Shortcut(key: .escape, modifiers: [.command, .option])) == .escape)
        #expect(ShortcutRule.rejection(for: Shortcut(key: .escape, modifiers: [])) == .escape)
    }

    @Test("the two shortcuts that would be destructive on every press are refused")
    func refusesReserved() {
        #expect(ShortcutRule.rejection(for: Shortcut(key: .letterQ, modifiers: [.command])) == .reserved)
        #expect(ShortcutRule.rejection(for: Shortcut(key: .letterW, modifiers: [.command])) == .reserved)
        #expect(ShortcutRule.rejection(for: Shortcut(key: .letterQ, modifiers: [.control])) == nil)
    }

    @Test("a modifier key cannot be the key that is tapped")
    func refusesModifierKey() {
        let command = Shortcut(key: KeyCode(rawValue: 55), modifiers: [.command])
        #expect(ShortcutRule.rejection(for: command) == .modifierKey)
        let function = Shortcut(key: KeyCode(rawValue: 63), modifiers: [.control])
        #expect(ShortcutRule.rejection(for: function) == .modifierKey)
        #expect(ShortcutRule.rejection(for: Shortcut(key: KeyCode(rawValue: 53), modifiers: [.command])) == .escape)
    }

    @Test("modifier bits with no meaning are dropped rather than armed")
    func normalisesUnknownModifiers() {
        let stray = Shortcut(key: .tab, modifiers: ModifierSet(rawValue: 0b0001_0001))
        #expect(ShortcutRule.normalised(stray) == .commandTab)
        let onlyStray = Shortcut(key: .tab, modifiers: ModifierSet(rawValue: 0b1000_0000))
        #expect(ShortcutRule.normalised(onlyStray) == .commandTab)
    }

    @Test("normalising leaves an acceptable shortcut alone and replaces a refused one")
    func normalisesRefused() {
        let accepted = Shortcut(key: .space, modifiers: [.control, .option])
        #expect(ShortcutRule.normalised(accepted) == accepted)
        #expect(ShortcutRule.normalised(Shortcut(key: KeyCode(rawValue: 56), modifiers: [.command])) == .commandTab)
    }
}
