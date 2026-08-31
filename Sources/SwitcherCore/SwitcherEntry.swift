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
