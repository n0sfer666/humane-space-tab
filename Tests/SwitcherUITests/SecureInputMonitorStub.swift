import SwitcherCore
import SystemPorts

@MainActor
final class SecureInputMonitorStub: SecureInputMonitor {
    var holder: SecureInputHolder?
}
