import SwitcherCore

@MainActor
public protocol WindowSource: Sendable {
    func windows() -> [WindowInfo]
}
