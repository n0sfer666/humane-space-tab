import Testing

@testable import SwitcherCore

@Suite("Permission state")
struct PermissionStateTests {
    @Test("without the permission the app offers to ask for it")
    func untrusted() {
        let state = PermissionState(isTrusted: false, tap: nil)
        #expect(state == .blocked(canAsk: true))
        #expect(state.needsAttention)
        #expect(state.offersGrant)
        #expect(state.detail?.contains("Accessibility") == true)
    }

    @Test("a refused tap despite the permission has nothing left to ask for")
    func trustedWithoutATap() {
        let state = PermissionState(isTrusted: true, tap: nil)
        #expect(state == .blocked(canAsk: false))
        #expect(state.needsAttention)
        #expect(state.offersGrant == false)
        #expect(state.detail?.isEmpty == false)
    }

    @Test("a tap that only observes is reported, not passed off as working")
    func observing() {
        let state = PermissionState(isTrusted: true, tap: .observe)
        #expect(state == .observing)
        #expect(state.needsAttention)
        #expect(state.offersGrant == false)
        #expect(state.detail?.isEmpty == false)
    }

    @Test("an intercepting tap is the quiet state")
    func intercepting() {
        let state = PermissionState(isTrusted: true, tap: .intercept)
        #expect(state == .intercepting)
        #expect(state.needsAttention == false)
        #expect(state.detail == nil)
    }
}
