import AppKit
import SwitcherCore

/// The one row in General whose state does not come from our preferences: the system, not
/// this window, decides whether the app opens at login, and it can be revoked in System
/// Settings without this window ever being opened.
@MainActor
final class LoginItemRow {
    let checkbox = NSButton(checkboxWithTitle: Localised.text(.generalOpenAtLogin), target: nil, action: nil)
    let note = NSTextField(wrappingLabelWithString: "")
    var noteRow: NSGridRow?

    private let item: LoginItem
    private let resize: @MainActor () -> Void

    init(item: LoginItem, resize: @escaping @MainActor () -> Void) {
        self.item = item
        self.resize = resize
        checkbox.target = self
        checkbox.action = #selector(toggled)
        note.font = .preferredFont(forTextStyle: .caption1)
        note.textColor = .secondaryLabelColor
        note.preferredMaxLayoutWidth = 320
        show()
    }

    func show() {
        let status = item.status
        let text = item.failure ?? LoginItemMessage.key(for: status).map(Localised.text)
        checkbox.state = status.isOn ? .on : .off
        note.stringValue = text ?? ""
        noteRow?.isHidden = text == nil
        resize()
    }

    @objc
    private func toggled() {
        item.set(checkbox.state == .on)
        show()
    }
}
