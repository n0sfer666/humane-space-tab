import Testing

@testable import SwitcherCore

@Suite("Preferences")
struct PreferencesTests {
    @Test("the defaults are the behaviour that shipped before the settings existed")
    func defaults() {
        let preferences = Preferences.standard
        #expect(preferences.revealDelay == 0.12)
        #expect(preferences.overlayScreen == .focused)
        #expect(preferences.usesPrivateSpaceLayer == false)
        #expect(preferences.shortcut == .commandTab)
    }

    @Test("a delay outside the range is clamped", arguments: [(-1.0, 0.0), (0.0, 0.0), (9.0, 0.5)])
    func clampsDelay(given: Double, expected: Double) {
        #expect(Preferences(revealDelay: given).revealDelay == expected)
    }

    @Test("a non-finite delay falls back to the default")
    func rejectsNonFiniteDelay() {
        #expect(Preferences(revealDelay: .nan).revealDelay == Preferences.standard.revealDelay)
        #expect(Preferences(revealDelay: .infinity).revealDelay == Preferences.standard.revealDelay)
    }

    @Test("the delay is quantised, so the slider and the stored value agree")
    func quantisesDelay() {
        #expect(Preferences(revealDelay: 0.1234).revealDelay == 0.12)
        #expect(Preferences(revealDelay: 0.1266).revealDelay == 0.13)
    }

    @Test("a shortcut the rules refuse is normalised to the default")
    func normalisesShortcut() {
        let refused = Shortcut(key: .tab, modifiers: [.command, .shift])
        #expect(Preferences(shortcut: refused).shortcut == .commandTab)
        let accepted = Shortcut(key: .tab, modifiers: [.option])
        #expect(Preferences(shortcut: accepted).shortcut == accepted)
    }

    @Test("a shortcut carrying modifier bits the app never sets is normalised too")
    func normalisesStrayModifierBits() {
        let stray = Shortcut(key: .tab, modifiers: ModifierSet(rawValue: 0b0001_0001))
        #expect(Preferences(shortcut: stray).shortcut == .commandTab)
    }

    @Test("a key with a layout-independent label carries its glyph")
    func namesKeys() {
        #expect(KeyCode.tab.glyph == "⇥")
        #expect(KeyCode.escape.glyph == "⎋")
        #expect(KeyCode(rawValue: 80).glyph == "F19")
        #expect(KeyCode.letterQ.glyph == nil)
    }

    @Test("an unknown or missing screen decodes to the default")
    func decodesScreen() {
        #expect(OverlayScreenChoice(stored: nil) == .focused)
        #expect(OverlayScreenChoice(stored: "sideways") == .focused)
        #expect(OverlayScreenChoice(stored: "pointer") == .pointer)
    }
}
