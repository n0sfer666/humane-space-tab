import SwitcherCore
import SystemPorts
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Session titles")
struct SessionTitlesTests {
    private final class SourceSpy: WindowTitleSource {
        var answers: [ProcessIdentifier: [WindowIdentifier: String]] = [:]
        var asked: [ProcessIdentifier] = []

        func titles(of process: ProcessIdentifier, windows: [WindowIdentifier]) -> [WindowIdentifier: String] {
            asked.append(process)
            return answers[process] ?? [:]
        }
    }

    private func entry(_ pid: Int32, window: UInt32?) -> SwitcherEntry {
        let application = SwitchableApplication(
            pid: ProcessIdentifier(rawValue: pid),
            bundleIdentifier: "test.\(pid)",
            name: "App \(pid)",
            isActive: false,
            windows: []
        )
        guard let window else { return SwitcherEntry(application: application) }
        return SwitcherEntry(
            application: application,
            window: ApplicationWindow(id: WindowIdentifier(rawValue: window), visibility: .onScreen)
        )
    }

    private func settle() async {
        for _ in 0..<8 { await Task.yield() }
    }

    @Test("a ribbon of applications asks for no title at all")
    func asksNothingForApplications() async {
        let source = SourceSpy()
        let titles = SessionTitles(source: source)
        titles.begin([entry(1, window: nil)]) { _ in }
        await settle()
        #expect(source.asked.isEmpty)
    }

    @Test("a title is reported against the entry it belongs to")
    func reportsTitles() async {
        let source = SourceSpy()
        source.answers[ProcessIdentifier(rawValue: 1)] = [WindowIdentifier(rawValue: 10): "Notes"]
        let titles = SessionTitles(source: source)
        var reported: [[SwitcherTarget: String]] = []
        titles.begin([entry(1, window: 10)]) { reported.append($0) }
        await settle()
        let target = SwitcherTarget(pid: ProcessIdentifier(rawValue: 1), window: WindowIdentifier(rawValue: 10))
        #expect(reported == [[target: "Notes"]])
        #expect(titles.known[target] == "Notes")
    }

    @Test("an application that answers nothing leaves its entries unlabelled")
    func survivesASilentApplication() async {
        let source = SourceSpy()
        let titles = SessionTitles(source: source)
        titles.begin([entry(1, window: 10)]) { _ in }
        await settle()
        #expect(titles.known.isEmpty)
        #expect(source.asked == [ProcessIdentifier(rawValue: 1)])
    }

    @Test("an answer to a session that ended is dropped")
    func dropsLateAnswers() async {
        let source = SourceSpy()
        source.answers[ProcessIdentifier(rawValue: 1)] = [WindowIdentifier(rawValue: 10): "Notes"]
        let titles = SessionTitles(source: source)
        var reported = 0
        titles.begin([entry(1, window: 10)]) { _ in reported += 1 }
        titles.end()
        await settle()
        #expect(reported == 0)
        #expect(source.asked.isEmpty)
        #expect(titles.known.isEmpty)
    }

    @Test("each application is asked once, in the ribbon's order")
    func asksEachApplicationOnce() async {
        let source = SourceSpy()
        let titles = SessionTitles(source: source)
        titles.begin([entry(2, window: 20), entry(1, window: 10), entry(2, window: 21)]) { _ in }
        await settle()
        #expect(source.asked == [2, 1].map(ProcessIdentifier.init(rawValue:)))
    }
}
