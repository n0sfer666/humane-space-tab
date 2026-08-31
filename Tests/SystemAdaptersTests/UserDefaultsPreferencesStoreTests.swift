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
                switchesWindows: true,
                shortcut: Shortcut(key: .space, modifiers: [.control, .option]),
                windowShortcut: Shortcut(key: .grave, modifiers: [.option])
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

    @Test("both readers of the window switching key agree on its name")
    func keepsWindowSwitchingKey() {
        withDefaults("window-switching") { defaults in
            defaults.set(true, forKey: "WindowSwitchingEnabled")
            #expect(UserDefaultsPreferencesStore(defaults: defaults).load().switchesWindows)
            #expect(UserDefaultsWindowSwitching(defaults: defaults).switchesWindows)
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

    @Test("an untouched domain reads the window shortcut as its own default")
    func readsWindowShortcutDefault() {
        withDefaults("window-shortcut-empty") { defaults in
            #expect(UserDefaultsPreferencesStore(defaults: defaults).load().windowShortcut == .commandGrave)
        }
    }

    @Test("a stored window shortcut the rules refuse falls back to its own default")
    func normalisesStoredWindowShortcut() {
        withDefaults("window-shortcut-nonsense") { defaults in
            defaults.set(50, forKey: PreferencesKey.windowShortcutKeyCode)
            defaults.set(Int(ModifierSet([.shift]).rawValue), forKey: PreferencesKey.windowShortcutModifiers)
            #expect(UserDefaultsPreferencesStore(defaults: defaults).load().windowShortcut == .commandGrave)
        }
    }

    @Test("the two shortcuts are stored under keys of their own")
    func storesBothShortcuts() {
        withDefaults("both-shortcuts") { defaults in
            let store = UserDefaultsPreferencesStore(defaults: defaults)
            store.save(
                Preferences(
                    shortcut: Shortcut(key: .space, modifiers: [.control]),
                    windowShortcut: Shortcut(key: .grave, modifiers: [.option])
                )
            )
            #expect(defaults.integer(forKey: PreferencesKey.shortcutKeyCode) == 49)
            #expect(defaults.integer(forKey: PreferencesKey.windowShortcutKeyCode) == 50)
            let loaded = store.load()
            #expect(loaded.shortcut == Shortcut(key: .space, modifiers: [.control]))
            #expect(loaded.windowShortcut == Shortcut(key: .grave, modifiers: [.option]))
        }
    }
}
