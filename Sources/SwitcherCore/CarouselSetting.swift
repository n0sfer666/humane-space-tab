/// Whether the ribbon turns, and how many slots it turns in. Off, the row holds every
/// entry still and shrinks to fit; on, the selection keeps its slot and the icons move
/// under it — the S07 carousel, with its width the one thing left open.
public struct CarouselSetting: Equatable, Sendable, Codable {
    public static let standard = CarouselSetting()
    public static let slotRange: ClosedRange<Int> = 5...12

    public let isEnabled: Bool
    public let slots: Int

    public init(isEnabled: Bool = true, slots: Int = 10) {
        self.isEnabled = isEnabled
        self.slots = min(max(slots, Self.slotRange.lowerBound), Self.slotRange.upperBound)
    }
}
