@MainActor
public final class PreferencesCenter {
    public private(set) var current: Preferences

    private let persist: @MainActor (Preferences) -> Void
    private var observers: [@MainActor (Preferences) -> Void] = []

    public init(initial: Preferences, persist: @escaping @MainActor (Preferences) -> Void) {
        current = initial
        self.persist = persist
    }

    /// The observer is called at once with the current value, so a consumer added at any
    /// point during launch starts from the same state as one added first.
    public func observe(_ observer: @escaping @MainActor (Preferences) -> Void) {
        observers.append(observer)
        observer(current)
    }

    public func update(_ preferences: Preferences) {
        guard preferences != current else { return }
        current = preferences
        persist(preferences)
        for observer in observers { observer(preferences) }
    }
}
