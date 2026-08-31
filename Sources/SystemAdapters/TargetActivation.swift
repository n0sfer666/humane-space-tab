import SwitcherCore
import SystemPorts

/// Turns what the ribbon chose into what the system does. An application entry is S06
/// untouched; a window entry is raised inside its application first, and the raise is
/// best-effort — a window the frame match could not name still leaves an application worth
/// activating, and reporting a failure for it would blame the switcher for a missing title.
@MainActor
public struct TargetActivation {
    private let activator: any ApplicationActivator
    private let raiser: any WindowRaiser

    public init(activator: any ApplicationActivator, raiser: any WindowRaiser) {
        self.activator = activator
        self.raiser = raiser
    }

    public func activate(_ target: SwitcherTarget) -> Bool {
        if let window = target.window {
            _ = raiser.raise(window, of: target.pid)
        }
        return activator.activate(target.pid)
    }
}
