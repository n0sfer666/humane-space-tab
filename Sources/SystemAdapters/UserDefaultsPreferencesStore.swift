import Foundation
import SwitcherCore
import SystemPorts

public struct UserDefaultsPreferencesStore: PreferencesStore {
    /// `UserDefaults` is documented as thread-safe; the inventory path reads it off the
    /// main actor, which is why this is not main-actor-isolated instead.
    nonisolated(unsafe) private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> Preferences {
        Preferences(
            revealDelay: delay(),
            overlayScreen: OverlayScreenChoice(stored: defaults.string(forKey: PreferencesKey.overlayScreen)),
            usesPrivateSpaceLayer: defaults.bool(forKey: PreferencesKey.privateSpaceLayer),
            switchesWindows: defaults.bool(forKey: PreferencesKey.windowSwitching),
            shortcut: shortcut()
        )
    }

    public func save(_ preferences: Preferences) {
        defaults.set(preferences.revealDelay, forKey: PreferencesKey.revealDelay)
        defaults.set(preferences.overlayScreen.rawValue, forKey: PreferencesKey.overlayScreen)
        defaults.set(preferences.usesPrivateSpaceLayer, forKey: PreferencesKey.privateSpaceLayer)
        defaults.set(preferences.switchesWindows, forKey: PreferencesKey.windowSwitching)
        defaults.set(Int(preferences.shortcut.key.rawValue), forKey: PreferencesKey.shortcutKeyCode)
        defaults.set(Int(preferences.shortcut.modifiers.rawValue), forKey: PreferencesKey.shortcutModifiers)
    }

    /// Either key missing means the user never chose; a stored pair that is out of range
    /// for the value types is nonsense on disk, and `Preferences` refuses the rest.
    private func shortcut() -> Shortcut {
        guard defaults.object(forKey: PreferencesKey.shortcutKeyCode) != nil,
            defaults.object(forKey: PreferencesKey.shortcutModifiers) != nil,
            let key = UInt16(exactly: defaults.integer(forKey: PreferencesKey.shortcutKeyCode)),
            let modifiers = UInt8(exactly: defaults.integer(forKey: PreferencesKey.shortcutModifiers))
        else { return Preferences.standard.shortcut }
        return Shortcut(key: KeyCode(rawValue: key), modifiers: ModifierSet(rawValue: modifiers))
    }

    /// A missing key is not a zero delay: both are legal, and only the absent one means
    /// the user never chose.
    private func delay() -> Double {
        guard defaults.object(forKey: PreferencesKey.revealDelay) != nil else {
            return Preferences.standard.revealDelay
        }
        return defaults.double(forKey: PreferencesKey.revealDelay)
    }
}
