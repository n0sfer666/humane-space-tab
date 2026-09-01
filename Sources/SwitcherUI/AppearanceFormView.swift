import AppKit
import SwitcherCore

/// The Appearance tab. Everything here belongs to a profile, so the profile comes first:
/// which one is on, what it is called, and the two ways to get another one. The built-in
/// profile is shown like the rest but cannot be edited — duplicating it is the way out, and
/// the note under the row says so rather than leaving a person to discover it by clicking.
@MainActor
final class AppearanceFormView: NSView, NSTextFieldDelegate {
    private let center: AppearanceCenter
    private let profiles = NSPopUpButton()
    private let name = NSTextField(string: "")
    private let duplicate = NSButton(title: "Duplicate", target: nil, action: nil)
    private let remove = NSButton(title: "Delete", target: nil, action: nil)
    private let note = NSTextField(wrappingLabelWithString: "")

    init(center: AppearanceCenter) {
        self.center = center
        super.init(frame: .zero)
        build()
        install(grid())
        center.observe { [weak self] in self?.show($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func build() {
        profiles.target = self
        profiles.action = #selector(chose)
        name.delegate = self
        name.target = self
        name.action = #selector(renamed)
        name.placeholderString = "Profile name"
        name.widthAnchor.constraint(equalToConstant: 200).isActive = true
        duplicate.target = self
        duplicate.action = #selector(duplicated)
        remove.target = self
        remove.action = #selector(deleted)
        note.font = .preferredFont(forTextStyle: .caption1)
        note.textColor = .secondaryLabelColor
        note.preferredMaxLayoutWidth = 320
    }

    private func show(_ book: AppearanceBook) {
        profiles.removeAllItems()
        profiles.addItems(withTitles: book.all.map(\.name))
        profiles.selectItem(at: book.all.firstIndex { $0.id == book.activeID } ?? 0)
        name.stringValue = book.active.name
        name.isEnabled = book.isEditable
        remove.isEnabled = book.isEditable
        duplicate.isEnabled = book.hasRoom
        note.stringValue = Self.note(for: book)
    }

    var shownProfiles: [String] { profiles.itemTitles }

    var shownName: String { name.stringValue }

    var shownNote: String { note.stringValue }

    var canRename: Bool { name.isEnabled }

    var canDuplicate: Bool { duplicate.isEnabled }

    var canDelete: Bool { remove.isEnabled }

    func choose(at index: Int) {
        let book = center.book
        guard let profile = book.all[safe: index] else { return }
        center.update(book.activating(profile.id))
    }

    func duplicateActive() {
        center.update(center.book.adding())
        window?.makeFirstResponder(name)
    }

    func deleteActive() {
        center.update(center.book.deletingActive())
    }

    /// A name that the book will not take — empty, or one already in use — is not left in
    /// the field to look accepted: the field goes back to what the profile is called.
    func rename(to value: String) {
        name.stringValue = value
        center.update(center.book.renamingActive(to: value))
        show(center.book)
    }

    @objc
    private func chose() {
        choose(at: profiles.indexOfSelectedItem)
    }

    @objc
    private func duplicated() {
        duplicateActive()
    }

    @objc
    private func deleted() {
        deleteActive()
    }

    @objc
    private func renamed() {
        rename(to: name.stringValue)
    }

    /// A name is taken when the field is left, not only when Return is pressed: clicking
    /// straight into another setting is the ordinary way to finish typing one.
    func controlTextDidEndEditing(_ notification: Notification) {
        renamed()
    }

    private func grid() -> NSGridView {
        let buttons = NSStackView(views: [duplicate, remove])
        buttons.spacing = 8
        let grid = NSGridView(views: [
            [Self.label("Profile"), profiles],
            [Self.label("Name"), name],
            [NSGridCell.emptyContentView, buttons],
            [NSGridCell.emptyContentView, note],
        ])
        grid.column(at: 0).xPlacement = .trailing
        grid.rowSpacing = 12
        grid.columnSpacing = 12
        return grid
    }

    private func install(_ grid: NSGridView) {
        grid.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: grid.trailingAnchor, constant: 20),
            bottomAnchor.constraint(equalTo: grid.bottomAnchor, constant: 20),
        ])
    }

    private static func note(for book: AppearanceBook) -> String {
        if book.isBuiltInActive {
            return """
                The built-in profile is what the ribbon looks like out of the box. \
                Duplicate it to make one you can change.
                """
        }
        let left = AppearanceBook.limit - book.profiles.count
        return left > 0
            ? "\(left) more profile\(left == 1 ? "" : "s") can be kept."
            : "All \(AppearanceBook.limit) profiles are in use. Delete one to make another."
    }

    private static func label(_ title: String) -> NSTextField {
        NSTextField(labelWithString: title)
    }
}

extension Array {
    fileprivate subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
