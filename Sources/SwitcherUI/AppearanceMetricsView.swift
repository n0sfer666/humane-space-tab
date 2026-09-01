import AppKit
import SwitcherCore

/// The sizes of the ribbon, six rows of the same shape. Every change is normalised against
/// the rest of the look before it is kept, and then every row is asked to redraw its range:
/// this is where the interlocking becomes visible — widening the gaps is what takes the
/// margin's room away, and the slider that lost it shows it at once.
@MainActor
final class AppearanceMetricsView: NSView {
    private let center: AppearanceCenter
    private var rows: [AppearanceMeasure: MeasureRow] = [:]

    init(center: AppearanceCenter) {
        self.center = center
        super.init(frame: .zero)
        for measure in AppearanceMeasure.allCases {
            rows[measure] = MeasureRow(unit: measure.unit) { [weak self] value in
                self?.changed(measure, to: value)
            }
        }
        install(grid())
        center.observe { [weak self] in self?.show($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var shownValues: [AppearanceMeasure: Double] { rows.mapValues(\.value) }

    var shownRanges: [AppearanceMeasure: ClosedRange<Double>] { rows.mapValues(\.shownRange) }

    var isEditable: Bool { rows[.iconSize]?.isOn ?? false }

    func change(_ measure: AppearanceMeasure, to value: Double) {
        changed(measure, to: value)
    }

    private func changed(_ measure: AppearanceMeasure, to value: Double) {
        center.edit { AppearanceLimits.normalise(measure.applying(value, to: $0), screenWidth: Self.screenWidth) }
        show(center.book)
    }

    private func show(_ book: AppearanceBook) {
        let appearance = book.active.appearance
        for (measure, row) in rows {
            row.show(
                measure.value(in: appearance),
                range: measure.range(in: appearance, screenWidth: Self.screenWidth),
                enabled: book.isEditable
            )
        }
    }

    private func grid() -> NSGridView {
        let grid = NSGridView(
            views: AppearanceMeasure.allCases.map { measure in
                [Self.label(measure.label), rows[measure] ?? NSGridCell.emptyContentView]
            })
        grid.column(at: 0).xPlacement = .trailing
        grid.column(at: 0).width = 150
        grid.column(at: 1).xPlacement = .leading
        grid.rowSpacing = 10
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

    /// The narrowest display the ribbon may end up on: a look settled on a wide screen has
    /// to stay sensible when the laptop is the only one left.
    private static var screenWidth: Double {
        NSScreen.screens.map { Double($0.frame.width) }.min() ?? AppearanceLimits.referenceWidth
    }

    private static func label(_ title: String) -> NSTextField {
        NSTextField(labelWithString: title)
    }
}
