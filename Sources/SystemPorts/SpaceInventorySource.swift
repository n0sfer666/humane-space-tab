import SwitcherCore

@MainActor
public protocol SpaceInventorySource: Sendable {
    /// The applications of the current Space, and the layer that answered which Space that is.
    func inventory() -> SpaceInventory

    /// The applications that own a window visible right now, front to back.
    func frontToBackApplications() -> [ProcessIdentifier]

    /// The windows visible right now, front to back: the stacking order S16 lists windows in.
    func frontToBackWindows() -> [WindowIdentifier]
}
