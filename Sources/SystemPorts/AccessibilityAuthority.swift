@MainActor
public protocol AccessibilityAuthority: AnyObject {
    var isTrusted: Bool { get }
    /// The system shows this prompt once per application; afterwards only System Settings
    /// can change the answer.
    func promptForTrust()
    func openSystemSettings()
}
