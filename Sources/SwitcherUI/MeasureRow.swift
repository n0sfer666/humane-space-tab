import AppKit

/// A number with two ways in: a slider for the feel of it, a field for a value already
/// known. Both write the same clamped number, and the field waits for Return or for the
/// focus to leave — a value taken mid-typing would fight the person halfway through "100".
@MainActor
final class MeasureRow: NSView, NSTextFieldDelegate {
    enum Unit {
        /// A length on screen, written as it is.
        case points
        /// A share of the icon, written as the percentage a person would say out loud.
        case percent

        var scale: Double { self == .percent ? 100 : 1 }
        var suffix: String { self == .percent ? "%" : "pt" }
    }

    private let unit: Unit
    private let slider = NSSlider()
    private let field = NSTextField(string: "")
    private let suffix: NSTextField
    private let onChange: @MainActor (Double) -> Void
    private var range: ClosedRange<Double> = 0...1

    init(unit: Unit, onChange: @escaping @MainActor (Double) -> Void) {
        self.unit = unit
        self.onChange = onChange
        suffix = NSTextField(labelWithString: unit.suffix)
        super.init(frame: .zero)
        build()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var value: Double { slider.doubleValue / unit.scale }

    var shownRange: ClosedRange<Double> { range }

    var isOn: Bool { slider.isEnabled }

    var shownText: String { field.stringValue }

    /// The range comes from the other settings and changes as they do, so a value that no
    /// longer fits is brought back rather than left showing something the ribbon will not do.
    func show(_ value: Double, range: ClosedRange<Double>, enabled: Bool) {
        self.range = range
        slider.minValue = range.lowerBound * unit.scale
        slider.maxValue = max(range.upperBound * unit.scale, range.lowerBound * unit.scale + 0.001)
        slider.doubleValue = min(max(value, range.lowerBound), range.upperBound) * unit.scale
        slider.isEnabled = enabled
        field.isEnabled = enabled
        suffix.textColor = enabled ? .secondaryLabelColor : .tertiaryLabelColor
        showValue()
    }

    private func build() {
        slider.isContinuous = true
        slider.target = self
        slider.action = #selector(dragged)
        slider.widthAnchor.constraint(equalToConstant: 180).isActive = true
        field.alignment = .right
        field.delegate = self
        field.target = self
        field.action = #selector(typed)
        field.widthAnchor.constraint(equalToConstant: 52).isActive = true
        suffix.font = .preferredFont(forTextStyle: .caption1)
        suffix.textColor = .secondaryLabelColor
        let stack = NSStackView(views: [slider, field, suffix])
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            bottomAnchor.constraint(equalTo: stack.bottomAnchor),
        ])
    }

    @objc
    private func dragged() {
        showValue()
        onChange(value)
    }

    @objc
    private func typed() {
        let asked = Double(field.stringValue.replacingOccurrences(of: ",", with: ".")) ?? slider.doubleValue
        let taken = min(max(asked / unit.scale, range.lowerBound), range.upperBound)
        slider.doubleValue = taken * unit.scale
        showValue()
        onChange(taken)
    }

    func controlTextDidEndEditing(_ notification: Notification) {
        typed()
    }

    private func showValue() {
        field.stringValue = "\(Int(slider.doubleValue.rounded()))"
    }
}
