import Foundation
import SwitcherCore
import Testing

@testable import SystemAdapters

@Suite("User defaults preferences store")
struct UserDefaultsPreferencesStoreTests {
    private func withDefaults(_ name: String, _ body: (UserDefaults) -> Void) {
        let suite = "io.github.n0sfer666.humane-space-tab.tests.\(name)"
        guard let defaults = UserDefaults(suiteName: suite) else {
            Issue.record("the test suite domain is unavailable")
            return
        }
        defaults.removePersistentDomain(forName: suite)
        body(defaults)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test("an untouched domain reads as the documented defaults")
    func readsDefaults() {
        withDefaults("empty") { defaults in
            #expect(UserDefaultsPreferencesStore(defaults: defaults).load() == .standard)
        }
    }

    @Test("saved preferences read back unchanged")
    func roundTrips() {
        withDefaults("round-trip") { defaults in
            let store = UserDefaultsPreferencesStore(defaults: defaults)
            let preferences = Preferences(
                revealDelay: 0.4,
                overlayScreen: .pointer,
                usesPrivateSpaceLayer: true,
                shortcut: Shortcut(key: .space, modifiers: [.control, .option])
            )
            store.save(preferences)
            #expect(store.load() == preferences)
        }
    }

    @Test("a hand-edited nonsense value is normalised on load")
    func normalisesStoredNonsense() {
        withDefaults("nonsense") { defaults in
            defaults.set(-5, forKey: PreferencesKey.revealDelay)
            defaults.set("sideways", forKey: PreferencesKey.overlayScreen)
            let loaded = UserDefaultsPreferencesStore(defaults: defaults).load()
            #expect(loaded.revealDelay == 0)
            #expect(loaded.overlayScreen == .focused)
        }
    }

    @Test("a stored shortcut the rules refuse falls back to the default")
    func normalisesStoredShortcut() {
        withDefaults("shortcut-nonsense") { defaults in
            defaults.set(48, forKey: PreferencesKey.shortcutKeyCode)
            defaults.set(Int(ModifierSet([.command, .shift]).rawValue), forKey: PreferencesKey.shortcutModifiers)
            #expect(UserDefaultsPreferencesStore(defaults: defaults).load().shortcut == .commandTab)
        }
    }

    @Test("stored modifier bits the app never writes leave a shortcut that still works")
    func dropsStrayStoredModifierBits() {
        withDefaults("shortcut-stray-bits") { defaults in
            defaults.set(49, forKey: PreferencesKey.shortcutKeyCode)
            defaults.set(0b0001_0100, forKey: PreferencesKey.shortcutModifiers)
            let loaded = UserDefaultsPreferencesStore(defaults: defaults).load().shortcut
            #expect(loaded == Shortcut(key: .space, modifiers: [.control]))
        }
    }

    @Test("a shortcut key without its modifiers is not half a shortcut")
    func ignoresHalfStoredShortcut() {
        withDefaults("shortcut-half") { defaults in
            defaults.set(49, forKey: PreferencesKey.shortcutKeyCode)
            #expect(UserDefaultsPreferencesStore(defaults: defaults).load().shortcut == .commandTab)
        }
    }

    @Test("the private layer keeps the key the space attribution already writes")
    func keepsSpaceLayerKey() {
        withDefaults("space-layer") { defaults in
            defaults.set(true, forKey: "PrivateSpaceLayerEnabled")
            #expect(UserDefaultsPreferencesStore(defaults: defaults).load().usesPrivateSpaceLayer)
            #expect(UserDefaultsSpaceLayerPreference(defaults: defaults).prefersPrivateLayer)
        }
    }
}
