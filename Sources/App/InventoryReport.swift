import Foundation
import SwitcherCore
import SystemPorts

@MainActor
struct InventoryReport {
    private let applications: any ApplicationSource
    private let windows: any WindowSource
    private let destination: any TextSink

    init(applications: any ApplicationSource, windows: any WindowSource, destination: any TextSink) {
        self.applications = applications
        self.windows = windows
        self.destination = destination
    }

    func copyToDestination() {
        let inventory = ApplicationInventory.build(
            applications: applications.runningApplications(),
            windows: windows.windows(),
            excluding: ProcessIdentifier(rawValue: ProcessInfo.processInfo.processIdentifier)
        )
        destination.write(InventorySummary.text(for: inventory))
    }
}
