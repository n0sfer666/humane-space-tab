import Testing

@testable import SwitcherCore

@Suite("Permission state")
struct PermissionStateTests {
    @Test("without the permission the app offers to ask for it")
    func untrusted() {
        let state = PermissionState(isTrusted: false, tap: nil, deliversKeys: true)
        #expect(state == .blocked(canAsk: true))
        #expect(state.needsAttention)
        #expect(state.offersGrant)
    }

    @Test("a refused tap despite the permission has nothing left to ask for")
    func trustedWithoutATap() {
        let state = PermissionState(isTrusted: true, tap: nil, deliversKeys: true)
        #expect(state == .blocked(canAsk: false))
        #expect(state.needsAttention)
        #expect(state.offersGrant == false)
    }

    @Test("a tap that only observes is reported, not passed off as working")
    func observing() {
        let state = PermissionState(isTrusted: true, tap: .observe, deliversKeys: true)
        #expect(state == .observing)
        #expect(state.needsAttention)
        #expect(state.offersGrant == false)
    }

    @Test("an intercepting tap is the quiet state")
    func intercepting() {
        let state = PermissionState(isTrusted: true, tap: .intercept, deliversKeys: true)
        #expect(state == .intercepting)
        #expect(state.needsAttention == false)
    }

    @Test("a tap that receives no key presses says so instead of claiming to work")
    func deafWhileIntercepting() {
        let state = PermissionState(isTrusted: true, tap: .intercept, deliversKeys: false)
        #expect(state == .deaf)
        #expect(state.needsAttention)
        #expect(state.offersInputMonitoring)
        #expect(state.offersGrant == false)
    }

    @Test("a deaf tap outranks an observing one, so the user is sent to the right list")
    func deafBeatsObserving() {
        #expect(PermissionState(isTrusted: true, tap: .observe, deliversKeys: false) == .deaf)
    }

    @Test("without a tap there is nothing to be deaf about")
    func noTapIsNotDeaf() {
        let state = PermissionState(isTrusted: true, tap: nil, deliversKeys: false)
        #expect(state == .blocked(canAsk: false))
        #expect(state.offersInputMonitoring == false)
    }

    @Test("the states that are not deaf offer no pane")
    func othersOfferNoPane() {
        let states: [PermissionState] = [.blocked(canAsk: true), .observing, .intercepting]
        #expect(states.allSatisfy { $0.offersInputMonitoring == false })
    }
}
