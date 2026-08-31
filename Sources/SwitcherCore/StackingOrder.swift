/// The live front-to-back order of the window server, turned into a sort. Both window
/// lists — S16's whole-ribbon expansion and S12's cycle through one application — order
/// their entries by it; what each of them lists is their own rule.
public struct StackingOrder: Sendable {
    private let rank: [WindowIdentifier: Int]

    public init(frontToBack: [WindowIdentifier]) {
        var rank: [WindowIdentifier: Int] = [:]
        for (position, window) in frontToBack.enumerated() where rank[window] == nil {
            rank[window] = position
        }
        self.rank = rank
    }

    /// Entries the stacking list does not name — minimised windows, windows of a hidden
    /// application, applications listed without one — keep the order they arrived in and
    /// follow the stacked ones.
    public func sorted(_ entries: [SwitcherEntry]) -> [SwitcherEntry] {
        var stacked: [(position: Int, entry: SwitcherEntry)] = []
        var appended: [SwitcherEntry] = []
        for entry in entries {
            if let window = entry.window?.id, let position = rank[window] {
                stacked.append((position, entry))
            } else {
                appended.append(entry)
            }
        }
        return stacked.sorted { $0.position < $1.position }.map(\.entry) + appended
    }
}
