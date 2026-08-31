public enum HotkeyInterpreter {
    private static let forceQuit: ModifierSet = [.command, .option]

    /// An open session is read against the one shortcut that opened it: the other binding
    /// shares the modifier often enough that reading a release against it would commit the
    /// session at the wrong moment.
    public static func decide(
        _ stroke: KeyStroke,
        shortcuts: ShortcutSet,
        session: SwitcherScope?
    ) -> HotkeyDecision {
        guard let session else { return decideWhileIdle(stroke, shortcuts) }
        return decideWithOpenSession(stroke, shortcuts.shortcut(for: session))
    }

    private static func decideWhileIdle(_ stroke: KeyStroke, _ shortcuts: ShortcutSet) -> HotkeyDecision {
        guard stroke.phase == .down, let matched = shortcuts.match(stroke) else { return .passThrough }
        return .command(.activate(matched.direction, matched.scope))
    }

    private static func decideWithOpenSession(_ stroke: KeyStroke, _ shortcut: Shortcut) -> HotkeyDecision {
        if stroke.key == .escape, stroke.modifiers.isSuperset(of: forceQuit) { return .passThrough }
        switch stroke.phase {
        case .flagsChanged:
            return shortcut.isHeld(in: stroke.modifiers) ? .consume : .command(.commit)
        case .up:
            return .consume
        case .down:
            if let direction = shortcut.direction(for: stroke) { return .command(.step(direction)) }
            return stroke.key == .escape ? .command(.cancel) : .consume
        }
    }
}
