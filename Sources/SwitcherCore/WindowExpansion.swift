/// Turns the application list into the window list of S16. Ordering is the live stacking
/// order and nothing else: a window's recency is readable from the window server, so no
/// second history is kept for it.
public enum WindowExpansion {
    public static func entries(
        applications: [SwitchableApplication],
        onCurrentSpace: Set<WindowIdentifier>,
        frontToBack: [WindowIdentifier]
    ) -> [SwitcherEntry] {
        let entries = applications.flatMap { application -> [SwitcherEntry] in
            let windows = listed(application, onCurrentSpace: onCurrentSpace)
            guard !windows.isEmpty else { return [SwitcherEntry(application: application)] }
            return windows.map { SwitcherEntry(application: application, window: $0) }
        }
        return StackingOrder(frontToBack: frontToBack).sorted(entries)
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
