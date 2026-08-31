import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
final class InventorySpy: SpaceInventorySource {
    var stack: [WindowIdentifier] = []
    var asked = 0

    func inventory() -> SpaceInventory {
        SpaceInventory(applications: [], layer: .onScreen)
    }

    func frontToBackApplications() -> [ProcessIdentifier] { [] }

    func frontToBackWindows() -> [WindowIdentifier] {
        asked += 1
        return stack
    }
}

struct Preference: WindowSwitchingPreference {
    let switchesWindows: Bool
}

@MainActor
final class IdentitySpy: WindowIdentitySource {
    var named: Set<WindowIdentifier>
    var asked: [ProcessIdentifier] = []
    var canIdentifyWindows = true

    init(named: [UInt32]) {
        self.named = Set(named.map(WindowIdentifier.init(rawValue:)))
    }

    func windows(
        of process: ProcessIdentifier,
        among candidates: Set<WindowIdentifier>
    ) -> Set<WindowIdentifier> {
        asked.append(process)
        return named.intersection(candidates)
    }
}

/// A clock that only moves when a test says so: the budget is a promise about what the
/// gesture costs, and a promise timed against the wall clock is untestable.
final class SteppingClock: @unchecked Sendable {
    private var instant = ContinuousClock.now
    var step: Duration = .zero

    func now() -> ContinuousClock.Instant {
        defer { instant = instant.advanced(by: step) }
        return instant
    }
}

func application(_ pid: Int32, windows: [UInt32]) -> SwitchableApplication {
    SwitchableApplication(
        pid: ProcessIdentifier(rawValue: pid),
        bundleIdentifier: "test.\(pid)",
        name: "App \(pid)",
        isActive: false,
        windows: windows.map { ApplicationWindow(id: WindowIdentifier(rawValue: $0), visibility: .onScreen) }
    )
}
