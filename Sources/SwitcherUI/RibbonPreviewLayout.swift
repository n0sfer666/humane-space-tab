import AppKit

/// Where the parts of the sample sit: the question at the top, the ribbon in the middle with
/// the room a wide Space would take, and the way out at the bottom.
@MainActor
enum RibbonPreviewLayout {
    static let stage = CGSize(width: 760, height: 260)

    static func make(counts: NSPopUpButton, start: NSButton, preview: NSView, done: NSButton) -> NSView {
        let question = NSStackView(views: [NSTextField(labelWithString: Localised.text(.previewCount)), counts, start])
        question.spacing = 10
        let footer = NSStackView(views: [NSView(), done])
        footer.distribution = .fill
        preview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            preview.widthAnchor.constraint(equalToConstant: stage.width),
            preview.heightAnchor.constraint(equalToConstant: stage.height),
        ])
        let stack = NSStackView(views: [question, preview, footer])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        footer.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -40).isActive = true
        return stack
    }
}
