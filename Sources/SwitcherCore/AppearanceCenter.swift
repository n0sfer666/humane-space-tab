/// The one place the profiles live while the app runs. It holds the book, hands changes to
/// whoever draws with them and to whoever writes them down — the same arrangement as
/// `PreferencesCenter`, kept apart because appearance changes on every drag of a slider and
/// the rest of the settings do not.
@MainActor
public final class AppearanceCenter {
    public private(set) var book: AppearanceBook

    private let persist: @MainActor (AppearanceBook) -> Void
    private var observers: [@MainActor (AppearanceBook) -> Void] = []

    public init(initial: AppearanceBook, persist: @escaping @MainActor (AppearanceBook) -> Void) {
        book = initial
        self.persist = persist
    }

    public var appearance: Appearance { book.active.appearance }

    /// The observer is called at once with the current book, so a consumer added at any
    /// point during launch starts from the same state as one added first.
    public func observe(_ observer: @escaping @MainActor (AppearanceBook) -> Void) {
        observers.append(observer)
        observer(book)
    }

    public func update(_ book: AppearanceBook) {
        guard book != self.book else { return }
        self.book = book
        persist(book)
        for observer in observers { observer(book) }
    }

    /// Editing goes through the book, so a change made while the built-in profile is on is
    /// quietly dropped rather than silently kept in a profile nobody can see.
    public func edit(_ change: (Appearance) -> Appearance) {
        update(book.updatingActive(change(book.active.appearance)))
    }
}
