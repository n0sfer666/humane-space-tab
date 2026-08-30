public enum ShortcutRecordingOutcome: Equatable, Sendable {
    case incomplete
    case cancelled
    case rejected(ShortcutRejection)
    case recorded(Shortcut)
}
