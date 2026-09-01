import SwitcherCore

/// What a login-item state says under the checkbox (S09). Only approval pending has
/// anything to say; the rest is either working or plainly off.
enum LoginItemMessage {
    static func key(for status: LoginItemStatus) -> UIText? {
        status == .requiresApproval ? .loginItemPending : nil
    }
}
