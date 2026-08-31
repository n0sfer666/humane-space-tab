/// What a committed session names: an application, or one of its windows.
public struct SwitcherTarget: Hashable, Sendable {
    public let pid: ProcessIdentifier
    public let window: WindowIdentifier?

    public init(pid: ProcessIdentifier, window: WindowIdentifier? = nil) {
        self.pid = pid
        self.window = window
    }
}
