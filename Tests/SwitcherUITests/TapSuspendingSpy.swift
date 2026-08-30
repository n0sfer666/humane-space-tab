@testable import SwitcherUI

@MainActor
final class TapSuspendingSpy: TapSuspending {
    private(set) var suspends = 0
    private(set) var resumes = 0

    func suspend() { suspends += 1 }
    func resume() { resumes += 1 }
}
