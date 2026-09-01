import Testing

@testable import SwitcherCore

@Suite("Empty session")
struct EmptySessionTests {
    @Test("an empty Space still gets a session to say so with")
    func emptyListOpensAnyway() {
        var machine = SwitcherMachine()
        #expect(machine.open([], .forward) == .opened)
        #expect(machine.session?.isEmpty == true)
    }

    @Test("a window session over an empty list opens nothing")
    func emptyWindowListIsIgnored() {
        var machine = SwitcherMachine()
        #expect(machine.open([], .forward, scope: .frontWindows) == .ignored)
        #expect(machine.session == nil)
    }

    @Test("committing an empty session closes it and raises nothing")
    func emptyCommitCloses() {
        var machine = SwitcherMachine()
        _ = machine.open([], .forward)
        #expect(machine.commit() == .cancelled)
        #expect(machine.session == nil)
    }

    @Test("stepping an empty session moves nothing")
    func emptyStepIsIgnored() {
        var machine = SwitcherMachine()
        _ = machine.open([], .forward)
        #expect(machine.step(.forward) == .ignored)
        #expect(machine.session?.selection == 0)
    }
}
