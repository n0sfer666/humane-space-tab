/// The list behind the window shortcut of S12: the windows the front application has on
/// this Space, and nothing else. A window of another Space or a minimised one is exactly
/// what the system's own shortcut gets wrong, so neither is listed here.
public enum FrontWindowCycle {
    public static func entries(
        front: SwitchableApplication?,
        onCurrentSpace: Set<WindowIdentifier>,
        frontToBack: [WindowIdentifier]
    ) -> [SwitcherEntry] {
        guard let front else { return [] }
        let entries = listed(front, onCurrentSpace: onCurrentSpace)
            .map { SwitcherEntry(application: front, window: $0) }
        return StackingOrder(frontToBack: frontToBack).sorted(entries)
    }

    /// A window of another Space or a minimised one is exactly what the system's own
    /// shortcut gets wrong, so neither is listed here.
    public static func listed(
        _ application: SwitchableApplication,
        onCurrentSpace: Set<WindowIdentifier>
    ) -> [ApplicationWindow] {
        application.windows.filter { onCurrentSpace.contains($0.id) && $0.visibility == .onScreen }
    }
}
