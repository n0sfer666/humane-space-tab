import SwitcherCore

public struct OverlayModel: Sendable, Equatable {
    public let applications: [SwitchableApplication]
    public let selection: Int

    public init(applications: [SwitchableApplication], selection: Int) {
        self.applications = applications
        self.selection = selection
    }

    public init(session: SwitcherSession) {
        self.init(applications: session.applications, selection: session.selection)
    }
}
