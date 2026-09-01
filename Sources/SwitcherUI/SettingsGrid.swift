import AppKit

/// The shape every settings form in this window has: a column of right-aligned titles of one
/// width, and the controls beside them. Kept in one place so the tabs line up with each other.
@MainActor
enum SettingsGrid {
    static let titleWidth: CGFloat = 150

    static func make(_ rows: [[NSView]]) -> NSGridView {
        let grid = NSGridView(views: rows)
        grid.column(at: 0).xPlacement = .trailing
        grid.column(at: 0).width = titleWidth
        grid.column(at: 1).xPlacement = .leading
        grid.rowSpacing = 10
        grid.columnSpacing = 12
        return grid
    }

    static func install(_ grid: NSGridView, in view: NSView) {
        grid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: view.topAnchor),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: grid.bottomAnchor),
        ])
    }

    static func label(_ title: String) -> NSTextField {
        NSTextField(labelWithString: title)
    }
}
