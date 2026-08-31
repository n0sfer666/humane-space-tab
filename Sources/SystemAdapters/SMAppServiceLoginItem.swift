import ServiceManagement
import SwitcherCore
import SystemPorts

@MainActor
public final class SMAppServiceLoginItem: LoginItemService {
    private let service: SMAppService

    public init(service: SMAppService = .mainApp) {
        self.service = service
    }

    /// `notFound` is what the system reports for a copy it has never been asked to register —
    /// not a refusal. Registering out of it succeeds, so it means the same thing here as
    /// `notRegistered`: off, and free to turn on.
    public var status: LoginItemStatus {
        switch service.status {
        case .enabled: .enabled
        case .requiresApproval: .requiresApproval
        default: .notRegistered
        }
    }

    public func register() throws {
        try service.register()
    }

    public func unregister() throws {
        try service.unregister()
    }
}
