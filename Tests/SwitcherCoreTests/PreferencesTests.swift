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

    @Test("an unknown or missing screen decodes to the default")
    func decodesScreen() {
        #expect(OverlayScreenChoice(stored: nil) == .focused)
        #expect(OverlayScreenChoice(stored: "sideways") == .focused)
        #expect(OverlayScreenChoice(stored: "pointer") == .pointer)
    }
}
