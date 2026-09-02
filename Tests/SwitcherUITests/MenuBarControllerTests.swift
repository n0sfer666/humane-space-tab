import AppKit
import SwitcherCore
import Testing

@testable import SwitcherUI

@MainActor
@Suite("Menu bar controller")
struct MenuBarControllerTests {
    private func titles(for state: PermissionState) -> [String] {
        let controller = MenuBarController(
            log: LogSpy(),
            openSettings: {},
            grantAccessibility: {},
            openInputMonitoring: {},
            copyInventory: {},
            quit: {}
        )
        controller.show(state)
        return controller.itemTitles
    }

    @Test("a deaf tap offers the pane that can cure it, and nothing to grant")
    func deafOffersThePane() {
        let titles = titles(for: .deaf)
        #expect(titles.contains("Open Input Monitoring…"))
        #expect(titles.contains("Grant Accessibility…") == false)
    }

    @Test("a working tap explains nothing and offers nothing")
    func interceptingIsQuiet() {
        let titles = titles(for: .intercepting)
        #expect(titles.contains("Open Input Monitoring…") == false)
        #expect(titles.contains("Grant Accessibility…") == false)
        #expect(titles.first == "Settings…")
    }

    @Test("a held session explains itself and offers neither the grant nor the pane")
    func securedExplainsItself() {
        let titles = titles(for: .secured(by: "Ghostty"))
        #expect(titles.first?.contains("Ghostty") == true)
        #expect(titles.contains("Grant Accessibility…") == false)
        #expect(titles.contains("Open Input Monitoring…") == false)
    }

    @Test("a missing permission offers the grant and not the pane")
    func blockedOffersTheGrant() {
        let titles = titles(for: .blocked(canAsk: true))
        #expect(titles.contains("Grant Accessibility…"))
        #expect(titles.contains("Open Input Monitoring…") == false)
    }
}
