import Testing

@testable import SwitcherCore

@Suite("Login item status")
struct LoginItemStatusTests {
    @Test("a registered item reads as on")
    func enabled() {
        #expect(LoginItemStatus.enabled.isOn)
    }

    @Test("an unregistered item reads as off")
    func notRegistered() {
        #expect(LoginItemStatus.notRegistered.isOn == false)
    }

    @Test("an item waiting for approval still reads as on")
    func requiresApproval() {
        #expect(LoginItemStatus.requiresApproval.isOn)
    }
}
