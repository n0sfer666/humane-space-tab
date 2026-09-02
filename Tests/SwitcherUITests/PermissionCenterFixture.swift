import SwitcherCore

@testable import SwitcherUI

@MainActor
final class PermissionCenterFixture {
    let authority = AccessibilityAuthorityStub()
    let engine = HotkeyEngineStub()
    let delivery = KeyEventDeliveryStub()
    let secureInput = SecureInputMonitorStub()
    let log = LogSpy()
    var moment = 0.0
    var ticks: [@MainActor () -> Void] = []
    lazy var center = PermissionCenter(
        authority: authority,
        engine: engine,
        delivery: delivery,
        secureInput: secureInput,
        log: log,
        now: { [unowned self] in self.moment },
        poll: { [unowned self] work in self.ticks.append(work) }
    )

    func tick(at moment: Double? = nil) {
        if let moment { self.moment = moment }
        let pending = ticks
        ticks = []
        for work in pending { work() }
    }
}
