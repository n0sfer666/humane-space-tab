import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Suspending shortcut recorder")
struct SuspendingShortcutRecorderTests {
    @Test("the switcher's tap is out of the way while a shortcut is recorded")
    func suspendsWhileRecording() {
        let suspension = TapSuspendingSpy()
        let inner = ShortcutRecorderSourceStub()
        let recorder = SuspendingShortcutRecorder(recorder: inner, suspension: suspension)
        #expect(recorder.start { _ in })
        #expect(suspension.suspends == 1)
        #expect(suspension.resumes == 0)
        recorder.stop()
        #expect(inner.stops == 1)
        #expect(suspension.resumes == 1)
    }

    @Test("a recorder that cannot capture leaves the switcher working")
    func restoresAfterFailure() {
        let suspension = TapSuspendingSpy()
        let recorder = SuspendingShortcutRecorder(
            recorder: ShortcutRecorderSourceStub(succeeds: false),
            suspension: suspension
        )
        #expect(recorder.start { _ in } == false)
        #expect(suspension.suspends == 1)
        #expect(suspension.resumes == 1)
    }

    @Test("a stop that answers no suspension leaves the tap alone")
    func ignoresUnpairedStop() {
        let suspension = TapSuspendingSpy()
        let inner = ShortcutRecorderSourceStub()
        let recorder = SuspendingShortcutRecorder(recorder: inner, suspension: suspension)
        recorder.stop()
        recorder.stop()
        #expect(suspension.resumes == 0)
        #expect(inner.stops == 2)
    }

    @Test("starting twice suspends once, so the single stop puts the tap back")
    func suspendsOnce() {
        let suspension = TapSuspendingSpy()
        let recorder = SuspendingShortcutRecorder(
            recorder: ShortcutRecorderSourceStub(),
            suspension: suspension
        )
        #expect(recorder.start { _ in })
        #expect(recorder.start { _ in })
        #expect(suspension.suspends == 1)
        recorder.stop()
        #expect(suspension.resumes == 1)
    }
}
