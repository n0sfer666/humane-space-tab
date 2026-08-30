public enum HotkeyInterpreter {
    private static let forceQuit: ModifierSet = [.command, .option]

    public static func decide(
        _ stroke: KeyStroke,
        shortcut: Shortcut,
        sessionOpen: Bool
    ) -> HotkeyDecision {
        sessionOpen ? decideWithOpenSession(stroke, shortcut) : decideWhileIdle(stroke, shortcut)
    }

    private static func decideWhileIdle(_ stroke: KeyStroke, _ shortcut: Shortcut) -> HotkeyDecision {
        guard stroke.phase == .down, let direction = shortcut.direction(for: stroke) else {
            return .passThrough
        }
        return .command(.activate(direction))
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
