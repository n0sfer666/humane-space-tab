import Foundation
import SwitcherCore
import SystemPorts

/// The profiles, written as one JSON value. Anything unreadable — a book from a version
/// that stored something else, a truncated write, a value edited by hand — is treated as no
/// book at all: the ribbon comes up in its built-in look rather than not coming up.
public struct UserDefaultsAppearanceStore: AppearanceStore {
    /// `UserDefaults` is documented as thread-safe; this store is not main-actor-isolated
    /// so that a launch path may read it before the main actor is up.
    nonisolated(unsafe) private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> AppearanceBook {
        guard
            let data = defaults.data(forKey: PreferencesKey.appearanceBook),
            let book = try? JSONDecoder().decode(AppearanceBook.self, from: data)
        else { return .standard }
        return book.normalised()
    }

    public func save(_ book: AppearanceBook) {
        guard let data = try? JSONEncoder().encode(book) else { return }
        defaults.set(data, forKey: PreferencesKey.appearanceBook)
    }
}
