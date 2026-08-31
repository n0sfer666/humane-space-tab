import SwitcherCore
import SystemPorts

/// The one place a gesture becomes a session change: the keyboard sends commands, the pointer
/// sends ribbon gestures, and both end in the same coordinator and the same ribbon.
@MainActor
public final class SessionRuntime {
    private let switcher: SwitcherCoordinator
    private let presenter: SessionPresenter
    private let log: any LogSink

    public init(switcher: SwitcherCoordinator, presenter: SessionPresenter, log: any LogSink) {
        self.switcher = switcher
        self.presenter = presenter
        self.log = log
    }

    public var isSessionOpen: Bool {
        switcher.isSessionOpen
    }

    public func perform(_ command: HotkeyCommand) {
        report(switcher.handle(command))
    }

    /// A gesture that changes nothing is dropped rather than reported: the pointer crosses a
    /// tile many times a second, and a ribbon that redraws on every one of them would pay for
    /// the mouse standing still.
    public func handle(_ gesture: RibbonGesture) {
        switch gesture {
        case .select(let index): report(ignoring: switcher.select(index))
        case .step(let direction): report(ignoring: switcher.handle(.step(direction)))
        case .commit(let index):
            guard switcher.isSessionOpen else { return }
            _ = switcher.select(index)
            report(ignoring: switcher.handle(.commit))
        }
    }

    public func end() {
        presenter.show(nil, opened: false)
    }

    public func recordActivation(of process: ProcessIdentifier) {
        switcher.recordActivation(of: process)
    }

    private func report(ignoring effect: SwitcherEffect) {
        guard effect != .ignored else { return }
        report(effect)
    }

    private func report(_ effect: SwitcherEffect) {
        log.record(LogEvent(effect: effect))
        presenter.show(switcher.session, opened: effect == .opened)
    }
}
