import SwitcherCore
import SystemPorts

@MainActor
final class LoginItemServiceStub: LoginItemService {
    var status: LoginItemStatus = .notRegistered
    var registered = 0
    var unregistered = 0
    var fails = false

    private struct Refused: Error {}

    func register() throws {
        registered += 1
        if fails { throw Refused() }
        status = .enabled
    }

    func unregister() throws {
        unregistered += 1
        if fails { throw Refused() }
        status = .notRegistered
    }
}
