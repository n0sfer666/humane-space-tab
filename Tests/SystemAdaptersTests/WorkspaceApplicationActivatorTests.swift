import AppKit
import Foundation
import SwitcherCore
import Testing

@testable import SystemAdapters

@MainActor
@Suite("Workspace application activator")
struct WorkspaceApplicationActivatorTests {
    @Test("a process that does not exist fails without raising anything")
    func missingProcessFails() {
        let activator = WorkspaceApplicationActivator()
        #expect(activator.activate(ProcessIdentifier(rawValue: -1)) == false)
    }

    @Test("a process that exists is handed to AppKit rather than rejected outright")
    func liveProcessReachesAppKit() {
        let activator = WorkspaceApplicationActivator()
        let own = ProcessIdentifier(rawValue: ProcessInfo.processInfo.processIdentifier)
        #expect(activator.activate(own) == NSRunningApplication.current.activate())
    }
}
