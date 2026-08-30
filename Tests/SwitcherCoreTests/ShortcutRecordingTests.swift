import Testing

@testable import SwitcherCore

@Suite("Shortcut recording")
struct ShortcutRecordingTests {
    @Test("modifiers alone keep the recorder waiting")
    func waitsForKey() {
        #expect(ShortcutRecording.outcome(key: nil, modifiers: [.command]) == .incomplete)
        #expect(ShortcutRecording.outcome(key: nil, modifiers: []) == .incomplete)
    }

    @Test("a valid combination is recorded")
    func records() {
        let expected = Shortcut(key: .tab, modifiers: [.option])
        #expect(ShortcutRecording.outcome(key: .tab, modifiers: [.option]) == .recorded(expected))
    }

    @Test("a refused combination reports its reason and keeps recording")
    func reportsRejection() {
        #expect(ShortcutRecording.outcome(key: .tab, modifiers: [.command, .shift]) == .rejected(.containsShift))
        #expect(ShortcutRecording.outcome(key: .tab, modifiers: []) == .rejected(.noModifier))
        #expect(ShortcutRecording.outcome(key: .letterQ, modifiers: [.command]) == .rejected(.reserved))
    }

    @Test("Escape on its own leaves the shortcut alone")
    func cancels() {
        #expect(ShortcutRecording.outcome(key: .escape, modifiers: []) == .cancelled)
        #expect(ShortcutRecording.outcome(key: .escape, modifiers: [.command]) == .rejected(.escape))
    }
}
