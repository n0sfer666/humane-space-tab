import SwitcherCore

/// What a permission state says in the menu (S10). The state is the core's; the sentence is
/// the interface's, because only the interface can be translated (S19).
@MainActor
enum PermissionMessage {
    static func text(for state: PermissionState) -> String? {
        switch state {
        case .blocked(canAsk: true): Localised.text(.permissionBlocked)
        case .blocked(canAsk: false): Localised.text(.permissionRefused)
        case .deaf: Localised.text(.permissionDeaf)
        case .secured(let holder): secured(by: holder)
        case .observing: Localised.text(.permissionObserving)
        case .intercepting: nil
        }
    }

    /// A hold nobody can name is still worth reporting: the advice that ends it — lock the
    /// screen and unlock it — does not depend on knowing who started it.
    private static func secured(by holder: String?) -> String {
        guard let holder else { return Localised.text(.permissionSecuredUnnamed) }
        return Localised.text(.permissionSecured, holder)
    }
}
