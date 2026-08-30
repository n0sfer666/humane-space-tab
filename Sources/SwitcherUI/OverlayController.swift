import Foundation

@MainActor
public final class OverlayController {
    public static let revealDelay: TimeInterval = 0.12
    /// A ribbon nobody has touched for this long belongs to a session that will never end:
    /// a tap killed mid-gesture leaves no way to dismiss a panel that ignores the mouse.
    public static let idleLimit: TimeInterval = 10

    private let surface: any OverlaySurface
    private let scheduler: any OverlayScheduler
    private let watchdog: any OverlayScheduler
    private let delay: TimeInterval
    private let limit: TimeInterval
    private var pending: OverlayModel?
    private var visible = false

    public init(
        surface: any OverlaySurface,
        scheduler: any OverlayScheduler,
        watchdog: any OverlayScheduler,
        delay: TimeInterval = OverlayController.revealDelay,
        limit: TimeInterval = OverlayController.idleLimit
    ) {
        self.surface = surface
        self.scheduler = scheduler
        self.watchdog = watchdog
        self.delay = delay
        self.limit = limit
    }

    public func render(_ model: OverlayModel?) {
        guard let model else { return end() }
        guard !visible else { return step(model) }
        let waiting = pending != nil
        pending = model
        guard !waiting else { return }
        scheduler.schedule(after: delay) { [weak self] in self?.reveal() }
    }

    private func step(_ model: OverlayModel) {
        surface.update(model)
        armWatchdog()
    }

    private func reveal() {
        guard let model = pending else { return }
        visible = true
        surface.show(model)
        armWatchdog()
    }

    private func armWatchdog() {
        watchdog.schedule(after: limit) { [weak self] in self?.dismiss() }
    }

    private func dismiss() {
        guard visible else { return }
        pending = nil
        visible = false
        surface.hide()
    }

    private func end() {
        scheduler.cancel()
        watchdog.cancel()
        pending = nil
        guard visible else { return }
        visible = false
        surface.hide()
    }
}
