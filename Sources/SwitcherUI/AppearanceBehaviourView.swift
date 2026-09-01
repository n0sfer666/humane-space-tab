import AppKit
import SwitcherCore

/// How the ribbon behaves in a session: which of the ways of showing a selection it uses,
/// and whether the row turns under that selection or stands still. The slots row is only
/// worth anything while the row turns, so it is switched off with it rather than hidden —
/// a control that disappears is one a person has to hunt for twice.
@MainActor
final class AppearanceBehaviourView: NSView {
    private let center: AppearanceCenter
    private let presets = NSPopUpButton(frame: .zero, pullsDown: false)
    private let turning = NSButton(checkboxWithTitle: "Turn the row under the selection", target: nil, action: nil)
    private lazy var slots = MeasureRow(unit: .slots) { [weak self] value in
        self?.changed(slots: value)
    }

    init(center: AppearanceCenter) {
        self.center = center
        super.init(frame: .zero)
        presets.addItems(withTitles: SelectionPreset.allCases.map(Self.title))
        presets.target = self
        presets.action = #selector(pickedPreset)
        turning.target = self
        turning.action = #selector(toggledCarousel)
        SettingsGrid.install(
            SettingsGrid.make([
                [SettingsGrid.label("Selection"), presets],
                [SettingsGrid.label("Carousel"), turning],
                [SettingsGrid.label("Slots"), slots],
            ]),
            in: self
        )
        center.observe { [weak self] in self?.show($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var shownPreset: SelectionPreset? {
        let index = presets.indexOfSelectedItem
        return SelectionPreset.allCases.indices.contains(index) ? SelectionPreset.allCases[index] : nil
    }

    var isTurning: Bool { turning.state == .on }

    var shownSlots: Int { Int(slots.value.rounded()) }

    var slotsAreOn: Bool { slots.isOn }

    var isEditable: Bool { presets.isEnabled }

    func choose(_ preset: SelectionPreset) {
        guard let index = SelectionPreset.allCases.firstIndex(of: preset) else { return }
        presets.selectItem(at: index)
        pickedPreset()
    }

    func turn(_ on: Bool) {
        turning.state = on ? .on : .off
        toggledCarousel()
    }

    func change(slots value: Int) {
        changed(slots: Double(value))
    }

    @objc
    private func pickedPreset() {
        guard let preset = shownPreset else { return }
        center.edit { $0.with(selection: preset) }
        show(center.book)
    }

    @objc
    private func toggledCarousel() {
        let on = isTurning
        center.edit { $0.with(carousel: CarouselSetting(isEnabled: on, slots: $0.carousel.slots)) }
        show(center.book)
    }

    private func changed(slots value: Double) {
        center.edit {
            $0.with(carousel: CarouselSetting(isEnabled: $0.carousel.isEnabled, slots: Int(value.rounded())))
        }
        show(center.book)
    }

    private func show(_ book: AppearanceBook) {
        let appearance = book.active.appearance
        if let index = SelectionPreset.allCases.firstIndex(of: appearance.selection) {
            presets.selectItem(at: index)
        }
        presets.isEnabled = book.isEditable
        turning.state = appearance.carousel.isEnabled ? .on : .off
        turning.isEnabled = book.isEditable
        slots.show(
            Double(appearance.carousel.slots),
            range: Double(CarouselSetting.slotRange.lowerBound)...Double(CarouselSetting.slotRange.upperBound),
            enabled: book.isEditable && appearance.carousel.isEnabled
        )
    }

    private static func title(_ preset: SelectionPreset) -> String {
        switch preset {
        case .native: "Like the system switcher"
        case .enlarged: "The selection grows"
        case .spotlight: "The selection stands alone"
        case .framed: "The selection is framed"
        }
    }
}
