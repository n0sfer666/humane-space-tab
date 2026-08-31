/// The Input Monitoring list, which is a different service from the one the accessibility
/// authority answers for. A port of its own so neither grows the other's pane.
@MainActor
public protocol InputMonitoringSettings: AnyObject {
    func open()
}
