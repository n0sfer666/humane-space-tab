import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Preferred space membership")
struct PreferredSpaceMembershipTests {
    private let candidate = WindowInfo(
        id: WindowIdentifier(rawValue: 10),
        owner: ProcessIdentifier(rawValue: 2),
        layer: 0,
        alpha: 1,
        isOnScreen: true
    )

    private func membership(
        prefersPrivate: Bool,
        privateAnswer: Set<WindowIdentifier>?,
        publicAnswer: Set<WindowIdentifier>? = [WindowIdentifier(rawValue: 10)],
        log: RecordingLogSink = RecordingLogSink()
    ) -> SpaceMembership {
        PreferredSpaceMembership(
            preference: SpaceLayerPreferenceStub(prefersPrivateLayer: prefersPrivate),
            privateLayer: SpaceMembershipStub(layer: .skyLight, answer: privateAnswer),
            publicLayer: SpaceMembershipStub(layer: .onScreen, answer: publicAnswer),
            log: log
        )
        .membership(among: [candidate])
    }

    @Test("without the preference the public layer answers")
    func publicByDefault() {
        let result = membership(prefersPrivate: false, privateAnswer: [])
        #expect(result.layer == .onScreen)
        #expect(result.windows == [WindowIdentifier(rawValue: 10)])
    }

    @Test("the private layer answers when it is preferred and available")
    func privateWhenPreferred() {
        let result = membership(prefersPrivate: true, privateAnswer: [WindowIdentifier(rawValue: 10)])
        #expect(result.layer == .skyLight)
    }

    @Test("an unavailable private layer falls back to the public one")
    func fallsBackWhenPrivateIsUnavailable() {
        let result = membership(prefersPrivate: true, privateAnswer: nil)
        #expect(result.layer == .onScreen)
        #expect(result.windows == [WindowIdentifier(rawValue: 10)])
    }

    @Test("falling back is logged")
    func fallbackIsLogged() {
        let log = RecordingLogSink()
        _ = membership(prefersPrivate: true, privateAnswer: nil, log: log)
        #expect(log.events == [.privateSpaceLayerUnavailable])
    }

    @Test("a layer that answers is never logged as unavailable")
    func availableLayerIsNotLogged() {
        let log = RecordingLogSink()
        _ = membership(prefersPrivate: true, privateAnswer: [], log: log)
        #expect(log.events.isEmpty)
    }

    @Test("both layers failing leaves an empty membership rather than a crash")
    func bothLayersUnavailable() {
        let result = membership(prefersPrivate: true, privateAnswer: nil, publicAnswer: nil)
        #expect(result.layer == .onScreen)
        #expect(result.windows.isEmpty)
    }
}
