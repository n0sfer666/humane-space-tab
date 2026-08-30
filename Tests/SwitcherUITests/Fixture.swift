import SwitcherUI

@MainActor
struct Fixture {
    let controller: OverlayController
    let surface: OverlaySurfaceSpy
    let scheduler: ManualOverlayScheduler
    let watchdog: ManualOverlayScheduler
}
