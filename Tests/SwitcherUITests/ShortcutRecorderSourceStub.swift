import SwitcherCore
import SystemPorts

@MainActor
final class ShortcutRecorderSourceStub: ShortcutRecorderSource {
    private let succeeds: Bool
    private var emit: (@MainActor (ShortcutRecordingOutcome) -> Void)?
    private(set) var starts = 0
    private(set) var stops = 0

    init(succeeds: Bool = true) {
        self.succeeds = succeeds
    }

    func start(emit: @escaping @MainActor (ShortcutRecordingOutcome) -> Void) -> Bool {
        starts += 1
        guard succeeds else { return false }
        self.emit = emit
        return true
    }

    func stop() {
        stops += 1
        emit = nil
    }

    func send(_ outcome: ShortcutRecordingOutcome) {
        emit?(outcome)
    }
}
