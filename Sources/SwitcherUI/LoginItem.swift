import SwitcherCore
import SystemPorts

@MainActor
public final class LoginItem {
    private let service: any LoginItemService
    private let log: any LogSink

    public var status: LoginItemStatus { service.status }

    public init(service: any LoginItemService, log: any LogSink) {
        self.service = service
        self.log = log
    }

    /// A refused change leaves the checkbox showing what the system reports, because the
    /// alternative is a checked box for a registration that never happened.
    public func set(_ enabled: Bool) {
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            log.record(.loginItemChangeFailed)
        }
    }
}
