public enum ShortcutRecording {
    /// Escape on its own is the way out of the recorder, so it never reaches the rule;
    /// Escape with modifiers is a combination the user meant, and is refused with its
    /// reason.
    public static func outcome(key: KeyCode?, modifiers: ModifierSet) -> ShortcutRecordingOutcome {
        guard let key else { return .incomplete }
        if key == .escape, modifiers.isEmpty { return .cancelled }
        let shortcut = Shortcut(key: key, modifiers: modifiers)
        if let rejection = ShortcutRule.rejection(for: shortcut) { return .rejected(rejection) }
        return .recorded(shortcut)
    }
}
