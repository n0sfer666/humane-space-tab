import SwitcherCore
import SystemPorts

/// The switcher's own tap has to be out of the way while a shortcut is recorded: it would
/// otherwise swallow the very combination the user is trying to type and open the ribbon
/// over the settings window.
@MainActor
public final class SuspendingShortcutRecorder: ShortcutRecorderSource {
    private let recorder: any ShortcutRecorderSource
    private let suspension: any TapSuspending
    private var isSuspended = false

    public init(recorder: any ShortcutRecorderSource, suspension: any TapSuspending) {
        self.recorder = recorder
        self.suspension = suspension
    }

    public func start(emit: @escaping @MainActor (ShortcutRecordingOutcome) -> Void) -> Bool {
        if !isSuspended {
            isSuspended = true
            suspension.suspend()
        }
        guard recorder.start(emit: emit) else {
            stop()
            return false
        }
        return true
    }

    /// Idempotent on purpose: the recorder is stopped by the field, by the window losing
    /// focus and by the outcome itself, and a resume for a suspension that never happened
    /// would start a tap nobody asked for.
    public func stop() {
        recorder.stop()
        guard isSuspended else { return }
        isSuspended = false
        suspension.resume()
    }
}
