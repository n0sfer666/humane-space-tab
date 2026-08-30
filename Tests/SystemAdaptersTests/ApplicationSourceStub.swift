import SwitcherCore
import SystemPorts

@MainActor
struct ApplicationSourceStub: ApplicationSource {
    let applications: [RunningApplication]

    func runningApplications() -> [RunningApplication] {
        applications
    }
}
