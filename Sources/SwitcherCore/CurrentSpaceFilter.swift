public enum CurrentSpaceFilter {
    public static func apply(
        to applications: [SwitchableApplication],
        windowsOnCurrentSpace: Set<WindowIdentifier>
    ) -> [SwitchableApplication] {
        applications.filter { application in
            application.windows.isEmpty
                || application.windows.contains { windowsOnCurrentSpace.contains($0.id) }
        }
    }
}
