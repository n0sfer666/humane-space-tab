import SwitcherCore

@MainActor
public protocol ShortcutRecorderSource: AnyObject {
    /// `false` when the keystrokes cannot be captured at all — without Accessibility the
    /// control has to say so rather than sit there recording nothing.
    func start(emit: @escaping @MainActor (ShortcutRecordingOutcome) -> Void) -> Bool
    func stop()
}
