import Testing

@testable import SwitcherCore

@Suite("Switcher machine")
struct SwitcherMachineTests {
    private func entries(_ count: Int) -> [SwitcherEntry] {
        (0..<count).map {
            SwitcherEntry(
                application: SwitchableApplication(
                    pid: ProcessIdentifier(rawValue: Int32($0 + 1)),
                    bundleIdentifier: "test.\($0)",
                    name: "App \($0)",
                    isActive: $0 == 0,
                    windows: []
                )
            )
        }
    }

    private func opened(_ count: Int, _ direction: SelectionDirection = .forward) -> SwitcherMachine {
        var machine = SwitcherMachine()
        _ = machine.open(entries(count), direction)
        return machine
    }

    @Test("opening forward selects the application before the front one")
    func opensForward() {
        var machine = SwitcherMachine()
        #expect(machine.open(entries(3), .forward) == .opened)
        #expect(machine.session?.selection == 1)
    }

    @Test("opening backward selects the last application")
    func opensBackward() {
        var machine = SwitcherMachine()
        #expect(machine.open(entries(3), .backward) == .opened)
        #expect(machine.session?.selection == 2)
    }

    @Test("stepping forward past the last application wraps to the first")
    func wrapsForward() {
        var machine = opened(3, .backward)
        #expect(machine.step(.forward) == .moved)
        #expect(machine.session?.selection == 0)
    }

    @Test("stepping backward past the first application wraps to the last")
    func wrapsBackward() {
        var machine = opened(3)
        #expect(machine.step(.backward) == .moved)
        #expect(machine.session?.selection == 0)
        #expect(machine.step(.backward) == .moved)
        #expect(machine.session?.selection == 2)
    }

    @Test("a single application is selected when the session opens")
    func singleApplicationOpens() {
        var machine = SwitcherMachine()
        #expect(machine.open(entries(1), .forward) == .opened)
        #expect(machine.session?.selection == 0)
    }

    @Test("stepping over a single application keeps the selection")
    func singleApplicationStays() {
        var machine = opened(1)
        #expect(machine.step(.forward) == .ignored)
        #expect(machine.session?.selection == 0)
    }

    @Test("opening over an empty list opens nothing")
    func emptyListIsIgnored() {
        var machine = SwitcherMachine()
        #expect(machine.open([], .forward) == .ignored)
        #expect(machine.session == nil)
    }

    @Test("opening a session while one is open leaves it untouched")
    func doubleOpenIsIgnored() {
        var machine = opened(3)
        #expect(machine.open(entries(5), .backward) == .ignored)
        #expect(machine.session?.entries.count == 3)
        #expect(machine.session?.selection == 1)
    }

    @Test("stepping without a session is ignored")
    func strayStepIsIgnored() {
        var machine = SwitcherMachine()
        #expect(machine.step(.forward) == .ignored)
        #expect(machine.session == nil)
    }

    @Test("cancelling without a session is ignored")
    func strayCancelIsIgnored() {
        var machine = SwitcherMachine()
        #expect(machine.cancel() == .ignored)
    }

    @Test("committing without a session is ignored")
    func strayCommitIsIgnored() {
        var machine = SwitcherMachine()
        #expect(machine.commit() == .ignored)
    }

    @Test("cancelling closes the session without choosing anything")
    func cancelClosesSession() {
        var machine = opened(3)
        #expect(machine.cancel() == .cancelled)
        #expect(machine.session == nil)
    }

    @Test("committing reports the selected application and closes the session")
    func commitReportsSelection() {
        var machine = opened(3)
        #expect(machine.commit() == .committed(SwitcherTarget(pid: ProcessIdentifier(rawValue: 2))))
        #expect(machine.session == nil)
    }

    @Test("committing after two steps reports the third application")
    func commitAfterSteps() {
        var machine = opened(3)
        _ = machine.step(.forward)
        #expect(machine.commit() == .committed(SwitcherTarget(pid: ProcessIdentifier(rawValue: 3))))
    }

    @Test("a session opened after a commit uses the new snapshot")
    func reopenUsesNewSnapshot() {
        var machine = opened(3)
        _ = machine.commit()
        #expect(machine.open(entries(2), .backward) == .opened)
        #expect(machine.session?.entries.count == 2)
        #expect(machine.session?.selection == 1)
    }

    @Test("selecting another entry moves the selection")
    func selectMoves() {
        var machine = opened(3)
        #expect(machine.select(2) == .moved)
        #expect(machine.session?.selection == 2)
    }

    @Test("selecting the entry already selected changes nothing")
    func selectSameIsIgnored() {
        var machine = opened(3)
        #expect(machine.select(1) == .ignored)
        #expect(machine.session?.selection == 1)
    }

    @Test("selecting outside the ribbon changes nothing")
    func selectOutOfRangeIsIgnored() {
        var machine = opened(3)
        #expect(machine.select(3) == .ignored)
        #expect(machine.select(-1) == .ignored)
        #expect(machine.session?.selection == 1)
    }

    @Test("selecting without a session changes nothing")
    func selectWithoutSessionIsIgnored() {
        var machine = SwitcherMachine()
        #expect(machine.select(0) == .ignored)
        #expect(machine.session == nil)
    }

    @Test("committing after a selection reports the selected entry")
    func commitAfterSelect() {
        var machine = opened(3)
        _ = machine.select(0)
        #expect(machine.commit() == .committed(SwitcherTarget(pid: ProcessIdentifier(rawValue: 1))))
    }
}
