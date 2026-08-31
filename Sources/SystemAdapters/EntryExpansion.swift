import SwitcherCore
import SystemPorts

/// Which unit the ribbon lists (S16). With the preference off nothing here asks the system
/// anything, so an app that switches applications makes no accessibility call at all.
@MainActor
public final class EntryExpansion {
    /// The whole accessibility pass happens inside the gesture, so it is bounded as a whole
    /// and not only per message: past this the remaining applications are listed as
    /// applications rather than risking the ~1 s at which the window server disables a tap.
    public static let budget: Duration = .milliseconds(60)

    private let inventory: any SpaceInventorySource
    private let preference: any WindowSwitchingPreference
    private let identity: any WindowIdentitySource
    private let log: any LogSink
    private let now: @MainActor () -> ContinuousClock.Instant
    private var reportedUnavailable = false

    public init(
        inventory: any SpaceInventorySource,
        preference: any WindowSwitchingPreference,
        identity: any WindowIdentitySource,
        log: any LogSink,
        now: @escaping @MainActor () -> ContinuousClock.Instant = { ContinuousClock.now }
    ) {
        self.inventory = inventory
        self.preference = preference
        self.identity = identity
        self.log = log
        self.now = now
    }

    public func entries(
        _ applications: [SwitchableApplication],
        onCurrentSpace: Set<WindowIdentifier>
    ) -> [SwitcherEntry] {
        guard preference.switchesWindows else {
            return applications.map { SwitcherEntry(application: $0) }
        }
        let confirmed = confirm(applications) {
            WindowExpansion.listed($0, onCurrentSpace: onCurrentSpace)
        }
        return WindowExpansion.entries(
            applications: confirmed,
            onCurrentSpace: onCurrentSpace,
            frontToBack: inventory.frontToBackWindows()
        )
    }

    /// The window shortcut of S12 lists windows whatever the preference says: that is the
    /// gesture, not a mode it can be in.
    public func cycle(
        _ applications: [SwitchableApplication],
        onCurrentSpace: Set<WindowIdentifier>
    ) -> [SwitcherEntry] {
        let front = applications.first.map { application in
            confirm([application]) { FrontWindowCycle.listed($0, onCurrentSpace: onCurrentSpace) }[0]
        }
        return FrontWindowCycle.entries(
            front: front,
            onCurrentSpace: onCurrentSpace,
            frontToBack: inventory.frontToBackWindows()
        )
    }

    /// Only the windows an application names itself become entries. An application that
    /// names none — it answers nothing, the grant is gone, or the budget ran out before its
    /// turn — keeps its single application entry, which is what S16 already does for one
    /// with no window here.
    private func confirm(
        _ applications: [SwitchableApplication],
        candidates: (SwitchableApplication) -> [ApplicationWindow]
    ) -> [SwitchableApplication] {
        let deadline = now().advanced(by: Self.budget)
        var named = false
        let confirmed = applications.map { application -> SwitchableApplication in
            let candidates = candidates(application)
            guard !candidates.isEmpty, now() < deadline else { return application.with(windows: []) }
            let confirmed = identity.windows(of: application.pid, among: Set(candidates.map(\.id)))
            named = named || !confirmed.isEmpty
            return application.with(windows: candidates.filter { confirmed.contains($0.id) })
        }
        report(named: named, asked: confirmed.count)
        return confirmed
    }

    /// A ribbon of applications is also what a missing symbol, a withdrawn grant and a
    /// machine full of wedged applications all look like, so the loss is said once rather
    /// than left to be noticed as an absent feature. The line names nothing (S00).
    private func report(named: Bool, asked: Int) {
        guard !named, asked > 0, !reportedUnavailable else { return }
        reportedUnavailable = true
        log.record(identity.canIdentifyWindows ? .windowListUnanswered : .windowListUnavailable)
    }
}
