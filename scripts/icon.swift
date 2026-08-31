import AppKit

/// The bundle icon, drawn rather than stored: a dark glass panel with the ribbon on it —
/// three applications, the middle one selected. Every size comes from the same drawing, so
/// the small ones stay the shape the large ones are.
enum IconArtwork {
    private static let reference: CGFloat = 1024
    private static let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    private static let corner: CGFloat = 185

    static func draw(in context: CGContext, side: CGFloat) {
        context.saveGState()
        context.scaleBy(x: side / reference, y: side / reference)
        let panel = CGPath(roundedRect: body, cornerWidth: corner, cornerHeight: corner, transform: nil)
        fillGlass(context, panel)
        addSheen(context, panel)
        strokeEdge(context, panel)
        drawRibbon(context)
        context.restoreGState()
    }

    private static func fillGlass(_ context: CGContext, _ panel: CGPath) {
        context.saveGState()
        context.addPath(panel)
        context.clip()
        gradient(
            context,
            colours: [
                CGColor(red: 0.204, green: 0.220, blue: 0.251, alpha: 1),
                CGColor(red: 0.078, green: 0.086, blue: 0.102, alpha: 1),
            ],
            from: CGPoint(x: body.midX, y: body.maxY),
            to: CGPoint(x: body.midX, y: body.minY)
        )
        context.restoreGState()
    }

    /// The light that tells the eye the panel is glass and not a painted square: strongest
    /// along the top edge, gone by the middle.
    private static func addSheen(_ context: CGContext, _ panel: CGPath) {
        context.saveGState()
        context.addPath(panel)
        context.clip()
        gradient(
            context,
            colours: [
                CGColor(gray: 1, alpha: 0.18),
                CGColor(gray: 1, alpha: 0),
            ],
            from: CGPoint(x: body.midX, y: body.maxY),
            to: CGPoint(x: body.midX, y: body.midY + 40)
        )
        context.restoreGState()
    }

    private static func strokeEdge(_ context: CGContext, _ panel: CGPath) {
        context.saveGState()
        context.addPath(panel)
        context.clip()
        context.addPath(panel)
        context.setLineWidth(8)
        context.setStrokeColor(CGColor(gray: 1, alpha: 0.14))
        context.strokePath()
        context.restoreGState()
    }

    /// The selection is the icon at full strength and full size, its neighbours the same
    /// icons dimmed and smaller — the ribbon's own rule, drawn at the size of an app icon.
    private static func drawRibbon(_ context: CGContext) {
        let step: CGFloat = 212
        dot(context, at: CGPoint(x: body.midX - step, y: body.midY), radius: 50, alpha: 0.52)
        dot(context, at: CGPoint(x: body.midX + step, y: body.midY), radius: 50, alpha: 0.52)
        glow(context, at: CGPoint(x: body.midX, y: body.midY), radius: 87)
        dot(context, at: CGPoint(x: body.midX, y: body.midY), radius: 87, alpha: 1)
    }

    private static func dot(_ context: CGContext, at centre: CGPoint, radius: CGFloat, alpha: CGFloat) {
        context.setFillColor(CGColor(red: 0.965, green: 0.976, blue: 0.988, alpha: alpha))
        context.fillEllipse(in: circle(at: centre, radius: radius))
    }

    private static func glow(_ context: CGContext, at centre: CGPoint, radius: CGFloat) {
        context.saveGState()
        context.setShadow(offset: .zero, blur: 72, color: CGColor(gray: 1, alpha: 0.55))
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fillEllipse(in: circle(at: centre, radius: radius))
        context.restoreGState()
    }

    private static func circle(at centre: CGPoint, radius: CGFloat) -> CGRect {
        CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)
    }

    private static func gradient(_ context: CGContext, colours: [CGColor], from: CGPoint, to: CGPoint) {
        guard
            let space = CGColorSpace(name: CGColorSpace.sRGB),
            let ramp = CGGradient(colorsSpace: space, colors: colours as CFArray, locations: [0, 1])
        else { return }
        context.drawLinearGradient(ramp, start: from, end: to, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }
}

enum IconWriter {
    static func png(side: Int) -> Data? {
        guard
            let rep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: side,
                pixelsHigh: side,
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: 0,
                bitsPerPixel: 0
            ),
            let context = NSGraphicsContext(bitmapImageRep: rep)
        else { return nil }
        IconArtwork.draw(in: context.cgContext, side: CGFloat(side))
        context.flushGraphics()
        return rep.representation(using: .png, properties: [:])
    }
}

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: swift scripts/icon.swift <iconset-directory>\n".utf8))
    exit(64)
}
let directory = URL(fileURLWithPath: arguments[1])
for point in [16, 32, 128, 256, 512] {
    for multiple in [1, 2] {
        let side = point * multiple
        guard let data = IconWriter.png(side: side) else {
            FileHandle.standardError.write(Data("error: could not render \(side)px\n".utf8))
            exit(1)
        }
        let suffix = multiple == 1 ? "" : "@2x"
        let name = "icon_\(point)x\(point)\(suffix).png"
        try data.write(to: directory.appendingPathComponent(name))
    }
}
