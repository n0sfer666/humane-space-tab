import AppKit
import SwitcherCore
import SwitcherUI
import SystemPorts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let log: any LogSink
    private var menuBar: MenuBarController?

    init(log: any LogSink) {
        self.log = log
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.record(.applicationDidLaunch)
        menuBar = MenuBarController(log: log) {
            NSApplication.shared.terminate(nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        log.record(.applicationWillTerminate)
    }
}
