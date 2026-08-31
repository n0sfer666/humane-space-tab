import SystemPorts

@MainActor
final class KeyEventDeliveryStub: KeyEventDelivery {
    var deliversKeyEvents = true
}
