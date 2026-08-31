import AppKit

/// The controls of one recorder row: the field showing the shortcut, the button putting the
/// default back, the one asking for Accessibility, and the line explaining a refusal. It
/// knows nothing about shortcuts — the row above it decides what each of them says.
@MainActor
final class ShortcutRecorderControls: NSView {
    private let field = NSButton(title: "", target: nil, action: nil)
    private let restore = NSButton(title: "Restore default", target: nil, action: nil)
    private let grant = NSButton(title: "Grant Accessibility…", target: nil, action: nil)
    private let reason = NSTextField(wrappingLabelWithString: "")
    private let onField: @MainActor () -> Void
    private let onRestore: @MainActor () -> Void
    private let onGrant: @MainActor () -> Void

    init(
        onField: @escaping @MainActor () -> Void,
        onRestore: @escaping @MainActor () -> Void,
        onGrant: @escaping @MainActor () -> Void
    ) {
        self.onField = onField
        self.onRestore = onRestore
        self.onGrant = onGrant
        super.init(frame: .zero)
        build()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var message: String {
        get { reason.stringValue }
        set { reason.stringValue = newValue }
    }

    var showsGrant: Bool {
        get { !grant.isHidden }
        set { grant.isHidden = !newValue }
    }

    func show(_ title: String, restoreEnabled: Bool) {
        field.title = title
        restore.isEnabled = restoreEnabled
    }

    private func build() {
        field.target = self
        field.action = #selector(fieldClicked)
        field.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        restore.target = self
        restore.action = #selector(restoreClicked)
        grant.target = self
        grant.action = #selector(grantClicked)
        grant.isHidden = true
        reason.font = .preferredFont(forTextStyle: .caption1)
        reason.textColor = .secondaryLabelColor
        reason.preferredMaxLayoutWidth = 320
        install()
    }

    private func install() {
        let row = NSStackView(views: [field, restore, grant])
        row.spacing = 8
        let column = NSStackView(views: [row, reason])
        column.orientation = .vertical
        column.alignment = .leading
        column.spacing = 4
        column.translatesAutoresizingMaskIntoConstraints = false
        addSubview(column)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: topAnchor),
            column.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: column.trailingAnchor),
            bottomAnchor.constraint(equalTo: column.bottomAnchor),
        ])
    }

    @objc
    private func fieldClicked() { onField() }

    @objc
    private func restoreClicked() { onRestore() }

    @objc
    private func grantClicked() { onGrant() }
}
