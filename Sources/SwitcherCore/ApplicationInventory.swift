public enum ApplicationInventory {
    public static func build(
        applications: [RunningApplication],
        windows: [WindowInfo],
        excluding own: ProcessIdentifier
    ) -> [SwitchableApplication] {
        let switchable = applications.filter { $0.policy == .regular && $0.pid != own }
        let byOwner = grouped(windows.filter(isRealWindow))
        return
            switchable
            .map { application in
                SwitchableApplication(
                    pid: application.pid,
                    bundleIdentifier: application.bundleIdentifier,
                    name: application.name,
                    isActive: application.isActive,
                    windows: (byOwner[application.pid] ?? []).map {
                        ApplicationWindow(id: $0.id, visibility: visibility(of: $0, isHidden: application.isHidden))
                    }
                )
            }
            .sorted(by: precedes)
    }

    private static func isRealWindow(_ window: WindowInfo) -> Bool {
        window.layer == 0 && window.alpha > 0
    }

    private static func grouped(_ windows: [WindowInfo]) -> [ProcessIdentifier: [WindowInfo]] {
        var groups: [ProcessIdentifier: [WindowInfo]] = [:]
        for window in windows {
            groups[window.owner, default: []].append(window)
        }
        return groups
    }

    private static func visibility(of window: WindowInfo, isHidden: Bool) -> WindowVisibility {
        if window.isOnScreen { return .onScreen }
        return isHidden ? .hiddenApplication : .minimised
    }

    private static func precedes(_ lhs: SwitchableApplication, _ rhs: SwitchableApplication) -> Bool {
        let left = lhs.name.lowercased()
        let right = rhs.name.lowercased()
        if left == right { return lhs.pid.rawValue < rhs.pid.rawValue }
        return left < right
    }
}
