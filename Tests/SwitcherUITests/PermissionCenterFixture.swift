import SwitcherCore

@testable import SwitcherUI

@MainActor
final class PermissionCenterFixture {
    let authority = AccessibilityAuthorityStub()
    let engine = HotkeyEngineStub()
    let delivery = KeyEventDeliveryStub()
    let log = LogSpy()
    var ticks: [@MainActor () -> Void] = []
    lazy var center = PermissionCenter(
        authority: authority,
        engine: engine,
        delivery: delivery,
        log: log,
        poll: { [unowned self] work in self.ticks.append(work) }
    )

    func tick() {
        let pending = ticks
        ticks = []
        for work in pending { work() }
    }
}
