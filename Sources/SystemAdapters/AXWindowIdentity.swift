import SwitcherCore
import SystemPorts

@MainActor
public struct AXWindowIdentity: WindowIdentitySource {
    public init() {}

    public var canIdentifyWindows: Bool { AXWindowElements.canIdentifyWindows }

    public func windows(
        of process: ProcessIdentifier,
        among candidates: Set<WindowIdentifier>
    ) -> Set<WindowIdentifier> {
        let elements = AXWindowElements.elements(
            of: process,
            wanted: candidates,
            timeout: AXWindowElements.listTimeout
        )
        return Set(elements.keys)
    }
}
