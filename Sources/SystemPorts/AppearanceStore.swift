import SwitcherCore

public protocol AppearanceStore: Sendable {
    func load() -> AppearanceBook
    func save(_ book: AppearanceBook)
}
