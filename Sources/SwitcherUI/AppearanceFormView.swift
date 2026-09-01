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
    private let duplicate = NSButton(title: Localised.text(.appearanceDuplicate), target: nil, action: nil)
    private let remove = NSButton(title: Localised.text(.appearanceDelete), target: nil, action: nil)
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
        name.placeholderString = Localised.text(.appearanceNamePlaceholder)
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
        profiles.addItems(withTitles: book.all.map(Self.title))
        profiles.selectItem(at: book.all.firstIndex { $0.id == book.activeID } ?? 0)
        name.stringValue = Self.title(book.active)
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
            [Self.label(Localised.text(.appearanceProfile)), profiles],
            [Self.label(Localised.text(.appearanceName)), name],
            [NSGridCell.emptyContentView, buttons],
            [NSGridCell.emptyContentView, note],
        ])
        grid.column(at: 0).xPlacement = .trailing
        grid.column(at: 0).width = 150
        grid.column(at: 1).xPlacement = .leading
        grid.rowSpacing = 12
        grid.columnSpacing = 12
        return grid
    }

    private func install(_ grid: NSGridView) {
        grid.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: topAnchor),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            bottomAnchor.constraint(equalTo: grid.bottomAnchor),
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
            : Localised.text(.appearanceFull, AppearanceBook.limit)
    }

    /// The built-in profile is the one name the user did not write, so it is the one name
    /// the interface translates.
    private static func title(_ profile: AppearanceProfile) -> String {
        profile.id == AppearanceBook.builtIn.id ? Localised.text(.appearanceBuiltIn) : profile.name
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
