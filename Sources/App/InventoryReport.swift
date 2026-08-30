import SwitcherCore
import SystemPorts

@MainActor
struct InventoryReport {
    private let inventory: any SpaceInventorySource
    private let destination: any TextSink

    init(inventory: any SpaceInventorySource, destination: any TextSink) {
        self.inventory = inventory
        self.destination = destination
    }

    func copyToDestination() {
        let current = inventory.inventory()
        destination.write(InventorySummary.text(for: current.applications, layer: current.layer))
    }
}
