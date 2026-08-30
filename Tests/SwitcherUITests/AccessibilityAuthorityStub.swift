import SystemPorts

@MainActor
final class AccessibilityAuthorityStub: AccessibilityAuthority {
    var isTrusted = false
    var prompts = 0
    var settingsOpened = 0

    func promptForTrust() {
        prompts += 1
    }

    func openSystemSettings() {
        settingsOpened += 1
    }
}
