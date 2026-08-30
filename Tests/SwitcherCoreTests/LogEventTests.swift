import Testing

@testable import SwitcherCore

@Suite("Log event")
struct LogEventTests {
    @Test("no case carries an associated value")
    func noAssociatedValues() {
        for event in LogEvent.allCases {
            #expect(Mirror(reflecting: event).children.isEmpty, "\(event)")
        }
    }

    @Test("every case has a non-empty static message")
    func everyCaseHasMessage() {
        for event in LogEvent.allCases {
            #expect(!event.message.isEmpty, "\(event)")
        }
    }

    @Test("messages are unique so a log line identifies its case")
    func messagesAreUnique() {
        let messages = LogEvent.allCases.map(\.message)
        #expect(Set(messages).count == messages.count)
    }

    @Test("lifecycle events are filed under the lifecycle category")
    func lifecycleCategory() {
        #expect(LogEvent.applicationDidLaunch.category == .lifecycle)
        #expect(LogEvent.applicationWillTerminate.category == .lifecycle)
    }

    @Test("every hotkey command maps to its own event in the hotkey category")
    func hotkeyCommandsMapToDistinctEvents() {
        let commands: [HotkeyCommand] = [
            .activate(.forward), .activate(.backward), .step(.forward), .step(.backward), .cancel, .commit,
        ]
        let events = commands.map(LogEvent.init(command:))
        #expect(Set(events).count == commands.count)
        for event in events { #expect(event.category == .hotkey) }
    }

    @Test("every switcher effect maps to its own event in the switcher category")
    func switcherEffectsMapToDistinctEvents() {
        let effects: [SwitcherEffect] = [
            .ignored, .opened, .moved, .cancelled, .committed(ProcessIdentifier(rawValue: 1)),
        ]
        let events = effects.map(LogEvent.init(effect:))
        #expect(Set(events).count == effects.count)
        for event in events { #expect(event.category == .switcher) }
    }

    @Test("a committed effect logs the same event whichever application it names")
    func commitEventCarriesNoTarget() {
        #expect(
            LogEvent(effect: .committed(ProcessIdentifier(rawValue: 1)))
                == LogEvent(effect: .committed(ProcessIdentifier(rawValue: 2)))
        )
    }

    @Test("every category is a stable identifier usable as an os.log category")
    func categoryIdentifiers() {
        for category in LogCategory.allCases {
            #expect(!category.rawValue.isEmpty)
            #expect(category.rawValue.allSatisfy { $0.isLowercase || $0.isNumber })
        }
    }
}
