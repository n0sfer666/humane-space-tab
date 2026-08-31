import Testing

@testable import SwitcherCore

@Suite("Hotkey interpreter, two shortcuts")
struct HotkeyInterpreterScopeTests {
    private func decide(
        _ key: KeyCode,
        _ modifiers: ModifierSet,
        _ phase: KeyPhase,
        session: SwitcherScope?
    ) -> HotkeyDecision {
        HotkeyInterpreter.decide(
            KeyStroke(key: key, modifiers: modifiers, phase: phase),
            shortcuts: .standard,
            session: session
        )
    }

    @Test("the window shortcut opens a session on the front application's windows")
    func windowShortcutActivates() {
        #expect(decide(.grave, [.command], .down, session: nil) == .command(.activate(.forward, .frontWindows)))
        #expect(
            decide(.grave, [.command, .shift], .down, session: nil)
                == .command(.activate(.backward, .frontWindows))
        )
    }

    @Test("a window session steps on its own shortcut")
    func windowSessionSteps() {
        #expect(decide(.grave, [.command], .down, session: .frontWindows) == .command(.step(.forward)))
        #expect(
            decide(.grave, [.command, .shift], .down, session: .frontWindows) == .command(.step(.backward))
        )
    }

    @Test("a window session commits when its modifier is released")
    func windowSessionCommits() {
        #expect(decide(.grave, [], .flagsChanged, session: .frontWindows) == .command(.commit))
        #expect(decide(.grave, [.command], .flagsChanged, session: .frontWindows) == .consume)
    }

    @Test("the other shortcut is swallowed while a session is open")
    func otherShortcutIsSwallowedWhileOpen() {
        #expect(decide(.tab, [.command], .down, session: .frontWindows) == .consume)
        #expect(decide(.grave, [.command], .down, session: .applications) == .consume)
    }

    @Test("escape cancels a window session")
    func escapeCancelsWindowSession() {
        #expect(decide(.escape, [.command], .down, session: .frontWindows) == .command(.cancel))
    }
}
