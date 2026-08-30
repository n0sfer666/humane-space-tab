import SwitcherCore
import SystemPorts
import Testing

@testable import SystemAdapters

@MainActor
@Suite("On-screen space membership")
struct OnScreenSpaceMembershipSourceTests {
    private let source = OnScreenSpaceMembershipSource()

    private func window(_ id: UInt32, isOnScreen: Bool) -> WindowInfo {
        WindowInfo(
            id: WindowIdentifier(rawValue: id),
            owner: ProcessIdentifier(rawValue: 2),
            layer: 0,
            alpha: 1,
            isOnScreen: isOnScreen
        )
    }

    @Test("the current space is the set of on-screen candidates")
    func onScreenCandidates() {
        let result = source.windowsOnCurrentSpace(among: [window(10, isOnScreen: true), window(11, isOnScreen: false)])
        #expect(result == [WindowIdentifier(rawValue: 10)])
    }

    @Test("the public layer always answers, even with nothing to look at")
    func alwaysAnswers() {
        #expect(source.windowsOnCurrentSpace(among: [])?.isEmpty == true)
    }
}
