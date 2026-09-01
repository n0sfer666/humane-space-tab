import Foundation
import SwitcherCore
import Testing

@testable import SystemAdapters

@Suite("User defaults appearance store")
struct UserDefaultsAppearanceStoreTests {
    private func withDefaults(_ name: String, _ body: (UserDefaults) -> Void) {
        let suite = "io.github.n0sfer666.humane-space-tab.tests.appearance.\(name)"
        guard let defaults = UserDefaults(suiteName: suite) else {
            Issue.record("the test suite domain is unavailable")
            return
        }
        defaults.removePersistentDomain(forName: suite)
        body(defaults)
        defaults.removePersistentDomain(forName: suite)
    }

    @Test("an untouched domain is the built-in profile")
    func readsDefaults() {
        withDefaults("empty") { defaults in
            #expect(UserDefaultsAppearanceStore(defaults: defaults).load() == .standard)
        }
    }

    @Test("a saved book reads back unchanged")
    func roundTrips() {
        withDefaults("round-trip") { defaults in
            let store = UserDefaultsAppearanceStore(defaults: defaults)
            let book = AppearanceBook.standard.adding(name: "Night").updatingActive(
                Appearance(iconSize: 72, selection: .native)
            )
            store.save(book)
            #expect(store.load() == book)
        }
    }

    @Test("a book that is not a book leaves the ribbon with its built-in look")
    func survivesRubbish() {
        withDefaults("rubbish") { defaults in
            defaults.set(Data("not json".utf8), forKey: PreferencesKey.appearanceBook)
            #expect(UserDefaultsAppearanceStore(defaults: defaults).load() == .standard)
        }
    }

    @Test("stored settings from another display are brought inside the bounds")
    func tamesStoredSettings() {
        withDefaults("bounds") { defaults in
            let store = UserDefaultsAppearanceStore(defaults: defaults)
            store.save(AppearanceBook.standard.adding().updatingActive(Appearance(iconSize: 9999)))
            #expect(store.load().active.appearance.iconSize == AppearanceLimits.largestIcon)
        }
    }
}
