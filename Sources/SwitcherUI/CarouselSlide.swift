import AppKit

/// The step, animated. The ribbon is drawn where it lands and the layer is slid in from where
/// it came, so a step costs one transform on the compositor rather than a second frame of
/// drawing — the keystroke that triggers it is on the critical path of a key tap.
@MainActor
enum CarouselSlide {
    static let duration = 0.12
    static let key = "carousel"

    static func apply(shift: Int, step: CGFloat, to layer: CALayer?) {
        guard let layer, shift != 0, step > 0 else { return }
        let slide = CABasicAnimation(keyPath: "transform.translation.x")
        slide.fromValue = CGFloat(shift) * step
        slide.toValue = 0
        slide.duration = duration
        slide.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(slide, forKey: key)
    }
}
