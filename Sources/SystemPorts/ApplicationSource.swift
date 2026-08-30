import SwitcherCore

@MainActor
public protocol ApplicationSource: Sendable {
    func runningApplications() -> [RunningApplication]
}
