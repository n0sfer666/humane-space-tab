import CoreGraphics
import SwitcherCore

enum TapEvent: Hashable {
    case stroke(KeyStroke)
    case disabled
    case ignored

    init(event: CGEvent, type: CGEventType) {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            self = .disabled
        default:
            self = KeyStroke(event: event, type: type).map(TapEvent.stroke) ?? .ignored
        }
    }
}
