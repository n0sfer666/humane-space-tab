import Testing

@testable import SwitcherCore

@MainActor
@Suite("Preferences centre")
struct PreferencesCenterTests {
    @Test("a changed value is published once and persisted")
    func publishesChange() {
        var saved: [Preferences] = []
        var seen: [Preferences] = []
        let center = PreferencesCenter(initial: .standard) { saved.append($0) }
        center.observe { seen.append($0) }
        center.update(Preferences(revealDelay: 0.3))
        #expect(center.current.revealDelay == 0.3)
        #expect(saved.map(\.revealDelay) == [0.3])
        #expect(seen.map(\.revealDelay) == [0.12, 0.3])
    }

    @Test("setting the same value again changes nothing")
    func ignoresRepeats() {
        var saved: [Preferences] = []
        var seen: [Preferences] = []
        let center = PreferencesCenter(initial: .standard) { saved.append($0) }
        center.observe { seen.append($0) }
        center.update(.standard)
        #expect(saved.isEmpty)
        #expect(seen.count == 1)
    }

    @Test("an observer added later starts from the current value")
    func lateObserverSeesCurrent() {
        var seen: [Preferences] = []
        let center = PreferencesCenter(initial: .standard) { _ in }
        center.update(Preferences(overlayScreen: .pointer))
        center.observe { seen.append($0) }
        #expect(seen.map(\.overlayScreen) == [.pointer])
    }
}
