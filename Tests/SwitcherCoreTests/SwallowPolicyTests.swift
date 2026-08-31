import Testing

@testable import SwitcherCore

@Suite("Swallow policy")
struct SwallowPolicyTests {
    private let tab = KeyStroke(key: .tab, modifiers: [.command], phase: .down)
    private let tabUp = KeyStroke(key: .tab, modifiers: [.command], phase: .up)
    private let release = KeyStroke(key: .tab, modifiers: [], phase: .flagsChanged)

    @Test("observing never swallows an event")
    func observeNeverSwallows() {
        var policy = SwallowPolicy(mode: .observe)
        let swallowed = [
            policy.swallows(.command(.activate(.forward, .applications)), of: tab),
            policy.swallows(.consume, of: tabUp),
            policy.swallows(.command(.commit), of: release),
        ]
        #expect(swallowed == [false, false, false])
    }

    @Test("intercepting swallows a key-down the switcher handled")
    func swallowsHandledDown() {
        var policy = SwallowPolicy(mode: .intercept)
        let swallowed = policy.swallows(.command(.activate(.forward, .applications)), of: tab)
        #expect(swallowed)
    }

    @Test("intercepting leaves an unhandled key-down alone")
    func leavesUnhandledDown() {
        var policy = SwallowPolicy(mode: .intercept)
        let swallowed = policy.swallows(.passThrough, of: tab)
        #expect(swallowed == false)
    }

    @Test("a modifier change always reaches other applications")
    func modifierChangePassesThrough() {
        var policy = SwallowPolicy(mode: .intercept)
        let commit = policy.swallows(.command(.commit), of: release)
        let held = policy.swallows(.consume, of: release)
        #expect(commit == false)
        #expect(held == false)
    }

    @Test("a key-up is swallowed only when its key-down was")
    func upFollowsItsDown() {
        var policy = SwallowPolicy(mode: .intercept)
        let stray = KeyStroke(key: KeyCode(rawValue: 12), modifiers: [.command], phase: .up)
        let unpaired = policy.swallows(.consume, of: stray)
        _ = policy.swallows(.command(.step(.forward)), of: tab)
        let paired = policy.swallows(.consume, of: tabUp)
        #expect(unpaired == false)
        #expect(paired)
    }

    @Test("a swallowed key-down is paired with exactly one key-up")
    func downIsPairedOnce() {
        var policy = SwallowPolicy(mode: .intercept)
        _ = policy.swallows(.command(.step(.forward)), of: tab)
        let first = policy.swallows(.consume, of: tabUp)
        let second = policy.swallows(.consume, of: tabUp)
        #expect(first)
        #expect(second == false)
    }
}
