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
            usesPrivateSpaceLayer: defaults.bool(forKey: PreferencesKey.privateSpaceLayer)
        )
    }

    public func save(_ preferences: Preferences) {
        defaults.set(preferences.revealDelay, forKey: PreferencesKey.revealDelay)
        defaults.set(preferences.overlayScreen.rawValue, forKey: PreferencesKey.overlayScreen)
        defaults.set(preferences.usesPrivateSpaceLayer, forKey: PreferencesKey.privateSpaceLayer)
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
