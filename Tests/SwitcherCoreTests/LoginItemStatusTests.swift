import Testing

@testable import SwitcherCore

@Suite("Login item status")
struct LoginItemStatusTests {
    @Test("a registered item reads as on and says nothing")
    func enabled() {
        #expect(LoginItemStatus.enabled.isOn)
        #expect(LoginItemStatus.enabled.message == nil)
    }

    @Test("an unregistered item reads as off and says nothing")
    func notRegistered() {
        #expect(LoginItemStatus.notRegistered.isOn == false)
        #expect(LoginItemStatus.notRegistered.message == nil)
    }

    @Test("an item waiting for approval reads as on and says where to approve it")
    func requiresApproval() {
        #expect(LoginItemStatus.requiresApproval.isOn)
        #expect(LoginItemStatus.requiresApproval.message?.contains("Login Items") == true)
    }
}
