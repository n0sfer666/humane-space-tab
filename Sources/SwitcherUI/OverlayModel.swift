import SwitcherCore

public struct OverlayModel: Sendable, Equatable {
    public let entries: [SwitcherEntry]
    public let selection: Int
    /// Window titles arrive after the ribbon does (S16), so an entry without one yet is
    /// labelled with its application's name instead.
    public let titles: [SwitcherTarget: String]

    public init(entries: [SwitcherEntry], selection: Int, titles: [SwitcherTarget: String] = [:]) {
        self.entries = entries
        self.selection = selection
        self.titles = titles
    }

    public init(session: SwitcherSession, titles: [SwitcherTarget: String] = [:]) {
        self.init(entries: session.entries, selection: session.selection, titles: titles)
    }

    public func label(of entry: SwitcherEntry) -> String {
        titles[entry.target] ?? entry.application.name
    }
}
