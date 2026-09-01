public enum PreferencesKey {
    public static let revealDelay = "RevealDelay"
    public static let overlayScreen = "OverlayScreen"
    /// The name the space attribution has written since S03; renaming it would silently
    /// reset a choice the user already made.
    public static let privateSpaceLayer = "PrivateSpaceLayerEnabled"
    public static let windowSwitching = "WindowSwitchingEnabled"
    public static let shortcutKeyCode = "ShortcutKeyCode"
    public static let shortcutModifiers = "ShortcutModifiers"
    public static let windowShortcutKeyCode = "WindowShortcutKeyCode"
    public static let windowShortcutModifiers = "WindowShortcutModifiers"
    /// The whole book of appearance profiles, as JSON: a profile is a tree, and one key
    /// keeps a stored book internally consistent where a key per number could not.
    public static let appearanceBook = "AppearanceBook"
}
