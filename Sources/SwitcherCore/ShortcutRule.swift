public enum ShortcutRule {
    public static let heldModifiers: ModifierSet = [.command, .control, .option]
    /// The virtual key codes of the modifier keys themselves. They arrive as modifier
    /// changes and never as a key press, so a shortcut armed on one could never fire.
    public static let modifierKeys: ClosedRange<UInt16> = 54...63
    public static let reserved: Set<Shortcut> = [
        Shortcut(key: .letterQ, modifiers: [.command]),
        Shortcut(key: .letterW, modifiers: [.command]),
    ]

    /// Shift is refused rather than tolerated: adding Shift to the activation is what
    /// reverses the direction, so a shortcut that already contains it has no backward
    /// gesture and would look broken instead of limited.
    /// `taken` is the shortcut the other gesture already holds (S12). Two gestures on one
    /// combination would leave one of them dead — the interpreter resolves the collision in
    /// a fixed order — so the recorder refuses it instead of stealing it silently.
    public static func rejection(for shortcut: Shortcut, taken: Shortcut? = nil) -> ShortcutRejection? {
        if shortcut.key == .escape { return .escape }
        if modifierKeys.contains(shortcut.key.rawValue) { return .modifierKey }
        if shortcut.modifiers.contains(.shift) { return .containsShift }
        if shortcut.modifiers.isDisjoint(with: heldModifiers) { return .noModifier }
        if reserved.contains(shortcut) { return .reserved }
        if shortcut == taken { return .taken }
        return nil
    }

    /// The stored shortcut is a file the user can edit by hand. Bits this type gives no
    /// meaning to are dropped rather than armed, because a modifier the tap can never see
    /// would leave the app with a shortcut nobody can press; what survives has to pass the
    /// rules or the default takes over.
    public static func normalised(_ shortcut: Shortcut, fallback: Shortcut = .commandTab) -> Shortcut {
        let masked = Shortcut(key: shortcut.key, modifiers: shortcut.modifiers.intersection(.known))
        return rejection(for: masked) == nil ? masked : fallback
    }
}
