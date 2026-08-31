import Testing

@testable import SwitcherCore

@Suite("Shortcut set")
struct ShortcutSetTests {
    private let shortcuts = ShortcutSet.standard

    private func match(
        _ key: KeyCode,
        _ modifiers: ModifierSet,
        in shortcuts: ShortcutSet? = nil
    ) -> (scope: SwitcherScope, direction: SelectionDirection)? {
        (shortcuts ?? self.shortcuts).match(KeyStroke(key: key, modifiers: modifiers, phase: .down))
    }

    @Test("the applications shortcut names the application scope")
    func matchesApplications() {
        let matched = match(.tab, [.command])
        #expect(matched?.scope == .applications)
        #expect(matched?.direction == .forward)
    }

    @Test("the window shortcut names the front-window scope")
    func matchesWindows() {
        let matched = match(.grave, [.command])
        #expect(matched?.scope == .frontWindows)
        #expect(matched?.direction == .forward)
    }

    @Test("shift reverses whichever shortcut was pressed")
    func shiftReverses() {
        #expect(match(.tab, [.command, .shift])?.direction == .backward)
        #expect(match(.grave, [.command, .shift])?.direction == .backward)
    }

    @Test("a stroke matching neither shortcut names no scope")
    func matchesNeither() {
        #expect(match(.space, [.command]) == nil)
        #expect(match(.grave, []) == nil)
    }

    @Test("two identical bindings resolve to the applications scope")
    func collisionPrefersApplications() {
        let collided = ShortcutSet(applications: .commandTab, frontWindows: .commandTab)
        #expect(match(.tab, [.command], in: collided)?.scope == .applications)
    }

    @Test("the set answers with the shortcut of a scope")
    func shortcutOfScope() {
        #expect(shortcuts.shortcut(for: .applications) == .commandTab)
        #expect(shortcuts.shortcut(for: .frontWindows) == .commandGrave)
    }

    @Test("the default window shortcut is command and the key left of one")
    func windowDefault() {
        #expect(Shortcut.commandGrave == Shortcut(key: .grave, modifiers: [.command]))
        #expect(KeyCode.grave.rawValue == 50)
    }
}
