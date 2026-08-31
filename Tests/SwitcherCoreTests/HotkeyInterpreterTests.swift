import Testing

@testable import SwitcherCore

@Suite("Hotkey interpreter")
struct HotkeyInterpreterTests {
    private let shortcut = Shortcut.commandTab

    private func decide(
        _ key: KeyCode,
        _ modifiers: ModifierSet,
        _ phase: KeyPhase,
        sessionOpen: Bool,
        shortcut: Shortcut? = nil
    ) -> HotkeyDecision {
        HotkeyInterpreter.decide(
            KeyStroke(key: key, modifiers: modifiers, phase: phase),
            shortcuts: ShortcutSet(applications: shortcut ?? self.shortcut),
            session: sessionOpen ? .applications : nil
        )
    }

    @Test("the shortcut opens a session moving forward")
    func shortcutActivatesForward() {
        #expect(decide(.tab, [.command], .down, sessionOpen: false) == .command(.activate(.forward, .applications)))
    }

    @Test("the shortcut with shift opens a session moving backward")
    func shortcutActivatesBackward() {
        #expect(
            decide(.tab, [.command, .shift], .down, sessionOpen: false) == .command(.activate(.backward, .applications))
        )
    }

    @Test("an extra modifier belongs to somebody else")
    func extraModifierPassesThrough() {
        #expect(decide(.tab, [.command, .control], .down, sessionOpen: false) == .passThrough)
        #expect(decide(.tab, [.command, .option], .down, sessionOpen: false) == .passThrough)
    }

    @Test("the shortcut key alone passes through")
    func bareKeyPassesThrough() {
        #expect(decide(.tab, [], .down, sessionOpen: false) == .passThrough)
    }

    @Test("key up of the shortcut passes through while idle")
    func shortcutKeyUpPassesThroughWhenIdle() {
        #expect(decide(.tab, [.command], .up, sessionOpen: false) == .passThrough)
    }

    @Test("unrelated keys pass through while idle")
    func unrelatedKeyPassesThroughWhenIdle() {
        #expect(decide(KeyCode(rawValue: 12), [], .down, sessionOpen: false) == .passThrough)
        #expect(decide(.escape, [], .down, sessionOpen: false) == .passThrough)
    }

    @Test("releasing the modifier while idle passes through")
    func modifierReleaseWhenIdlePassesThrough() {
        #expect(decide(.tab, [], .flagsChanged, sessionOpen: false) == .passThrough)
    }

    @Test("the shortcut steps forward while a session is open")
    func shortcutStepsForward() {
        #expect(decide(.tab, [.command], .down, sessionOpen: true) == .command(.step(.forward)))
    }

    @Test("the shortcut with shift steps backward while a session is open")
    func shortcutStepsBackward() {
        #expect(decide(.tab, [.command, .shift], .down, sessionOpen: true) == .command(.step(.backward)))
    }

    @Test("escape cancels an open session")
    func escapeCancels() {
        #expect(decide(.escape, [.command], .down, sessionOpen: true) == .command(.cancel))
    }

    @Test("releasing the shortcut modifiers commits the session")
    func modifierReleaseCommits() {
        #expect(decide(.tab, [], .flagsChanged, sessionOpen: true) == .command(.commit))
    }

    @Test("holding the shortcut modifiers keeps the session open")
    func modifierStillHeldConsumes() {
        #expect(decide(.tab, [.command, .shift], .flagsChanged, sessionOpen: true) == .consume)
    }

    @Test("key up is swallowed while a session is open")
    func keyUpConsumedWhileOpen() {
        #expect(decide(.tab, [.command], .up, sessionOpen: true) == .consume)
    }

    @Test("unmapped keys are swallowed while a session is open")
    func unmappedKeyConsumedWhileOpen() {
        #expect(decide(KeyCode(rawValue: 12), [.command], .down, sessionOpen: true) == .consume)
    }

    @Test("a custom shortcut activates and the default one stops working")
    func customShortcutReplacesTheDefault() {
        let custom = Shortcut(key: KeyCode(rawValue: 50), modifiers: [.option])
        #expect(
            decide(KeyCode(rawValue: 50), [.option], .down, sessionOpen: false, shortcut: custom)
                == .command(.activate(.forward, .applications))
        )
        #expect(decide(.tab, [.command], .down, sessionOpen: false, shortcut: custom) == .passThrough)
    }

    @Test("a multi-modifier shortcut needs every modifier")
    func multiModifierShortcut() {
        let custom = Shortcut(key: .tab, modifiers: [.control, .option])
        #expect(
            decide(.tab, [.control, .option], .down, sessionOpen: false, shortcut: custom)
                == .command(.activate(.forward, .applications))
        )
        #expect(decide(.tab, [.control], .down, sessionOpen: false, shortcut: custom) == .passThrough)
        #expect(
            decide(.tab, [.control, .option], .flagsChanged, sessionOpen: true, shortcut: custom)
                == .consume
        )
        #expect(
            decide(.tab, [.control], .flagsChanged, sessionOpen: true, shortcut: custom)
                == .command(.commit)
        )
    }

    @Test("force quit stays with the system while a session is open")
    func forceQuitPassesThrough() {
        #expect(decide(.escape, [.command, .option], .down, sessionOpen: true) == .passThrough)
        #expect(decide(.escape, [.command, .option, .shift], .down, sessionOpen: true) == .passThrough)
        #expect(decide(.escape, [.command, .option], .up, sessionOpen: true) == .passThrough)
        #expect(decide(.escape, [.option], .down, sessionOpen: true) == .command(.cancel))
    }

    @Test("a shortcut that already holds shift only ever moves forward")
    func shortcutContainingShiftHasNoBackwardStep() {
        let custom = Shortcut(key: .tab, modifiers: [.command, .shift])
        #expect(
            decide(.tab, [.command, .shift], .down, sessionOpen: false, shortcut: custom)
                == .command(.activate(.forward, .applications))
        )
        #expect(decide(.tab, [.command], .down, sessionOpen: false, shortcut: custom) == .passThrough)
    }

    @Test("a shortcut without modifiers never commits on a flag change")
    func modifierlessShortcutNeverCommits() {
        let custom = Shortcut(key: KeyCode(rawValue: 80), modifiers: [])
        #expect(decide(KeyCode(rawValue: 80), [], .flagsChanged, sessionOpen: true, shortcut: custom) == .consume)
        #expect(
            decide(KeyCode(rawValue: 80), [], .down, sessionOpen: false, shortcut: custom)
                == .command(.activate(.forward, .applications))
        )
    }
}
