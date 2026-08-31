import SwitcherCore

public struct OverlayModel: Sendable, Equatable {
    public let entries: [SwitcherEntry]
    public let selection: Int

    public init(entries: [SwitcherEntry], selection: Int) {
        self.entries = entries
        self.selection = selection
    }

    public init(session: SwitcherSession) {
        self.init(entries: session.entries, selection: session.selection)
    }
}
