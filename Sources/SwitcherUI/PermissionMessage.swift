import SwitcherCore

/// What a permission state says in the menu (S10). The state is the core's; the sentence is
/// the interface's, because only the interface can be translated (S19).
enum PermissionMessage {
    static func key(for state: PermissionState) -> UIText? {
        switch state {
        case .blocked(canAsk: true): .permissionBlocked
        case .blocked(canAsk: false): .permissionRefused
        case .deaf: .permissionDeaf
        case .observing: .permissionObserving
        case .intercepting: nil
        }
    }
}
