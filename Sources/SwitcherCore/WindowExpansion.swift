/// Turns the application list into the window list of S16. Ordering is the live stacking
/// order and nothing else: a window's recency is readable from the window server, so no
/// second history is kept for it.
public enum WindowExpansion {
    public static func entries(
        applications: [SwitchableApplication],
        onCurrentSpace: Set<WindowIdentifier>,
        frontToBack: [WindowIdentifier]
    ) -> [SwitcherEntry] {
        var rank: [WindowIdentifier: Int] = [:]
        for (position, window) in frontToBack.enumerated() where rank[window] == nil {
            rank[window] = position
        }
        var stacked: [(position: Int, entry: SwitcherEntry)] = []
        var appended: [SwitcherEntry] = []
        for application in applications {
            let windows = listed(application, onCurrentSpace: onCurrentSpace)
            guard !windows.isEmpty else {
                appended.append(SwitcherEntry(application: application))
                continue
            }
            for window in windows {
                let entry = SwitcherEntry(application: application, window: window)
                if let position = rank[window.id] {
                    stacked.append((position, entry))
                } else {
                    appended.append(entry)
                }
            }
        }
        return stacked.sorted { $0.position < $1.position }.map(\.entry) + appended
    }

    /// The windows this Space can show: the ones it holds, plus the ones no Space claims —
    /// minimised and hidden windows are placed by neither layer of S03.
    private static func listed(
        _ application: SwitchableApplication,
        onCurrentSpace: Set<WindowIdentifier>
    ) -> [ApplicationWindow] {
        application.windows.filter {
            onCurrentSpace.contains($0.id) || $0.visibility != .onScreen
        }
    }
}
