/// One slot of the ribbon. A window is carried only in window mode (S16); with the
/// preference off every entry names an application and nothing else.
public struct SwitcherEntry: Sendable, Equatable {
    public let application: SwitchableApplication
    public let window: ApplicationWindow?

    public init(application: SwitchableApplication, window: ApplicationWindow? = nil) {
        self.application = application
        self.window = window
    }

    public var target: SwitcherTarget {
        SwitcherTarget(pid: application.pid, window: window?.id)
    }
}

extension SwitcherEntry {
    /// The ribbon before S16's preference expands it: one entry per application, and the
    /// Space's window set left unread.
    public static func applications(
        _ applications: [SwitchableApplication],
        _: Set<WindowIdentifier>
    ) -> [SwitcherEntry] {
        applications.map { SwitcherEntry(application: $0) }
    }
}
