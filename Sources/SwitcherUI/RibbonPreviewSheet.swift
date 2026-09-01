import AppKit
import SwitcherCore

/// The sample: pick how many applications the Space would have, press Show, and watch four
/// seconds of the ribbon with the selection moving on once a second. It never opens the
/// panel, so looking at a hundred applications costs the Space nothing.
@MainActor
final class RibbonPreviewSheet: NSViewController {
    private let center: AppearanceCenter
    private let counts = NSPopUpButton(frame: .zero, pullsDown: false)
    private let start = NSButton(title: Localised.text(.previewShow), target: nil, action: nil)
    private let preview: RibbonPreviewView
    private var run: RibbonPreviewRun?
    private var ticker: Timer?

    init(center: AppearanceCenter) {
        self.center = center
        preview = RibbonPreviewView(icons: PreviewIcons(), appearance: center.appearance)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var chosenCount: Int { PreviewEntries.counts[counts.indexOfSelectedItem] }

    var shownSelection: Int { run?.selection ?? 0 }

    var isRunning: Bool { run?.isRunning ?? false }

    func choose(count: Int) {
        guard let index = PreviewEntries.counts.firstIndex(of: count) else { return }
        counts.selectItem(at: index)
        draw()
    }

    func begin() {
        run = RibbonPreviewRun(count: chosenCount)
        draw()
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: RibbonPreviewRun.interval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.advance()
                if !self.isRunning { self.stop() }
            }
        }
    }

    func advance() {
        run?.step()
        draw()
    }

    override func loadView() {
        counts.addItems(withTitles: PreviewEntries.counts.map(String.init))
        counts.selectItem(at: PreviewEntries.counts.firstIndex(of: 10) ?? 0)
        counts.target = self
        counts.action = #selector(pickedCount)
        start.target = self
        start.action = #selector(pressedShow)
        start.bezelStyle = .rounded
        start.keyEquivalent = "\r"
        view = RibbonPreviewLayout.make(counts: counts, start: start, preview: preview, done: done())
        draw()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        stop()
    }

    private func stop() {
        ticker?.invalidate()
        ticker = nil
    }

    private func done() -> NSButton {
        let button = NSButton(title: Localised.text(.previewDone), target: self, action: #selector(pressedDone))
        button.bezelStyle = .rounded
        button.keyEquivalent = "\u{1b}"
        return button
    }

    @objc
    private func pickedCount() {
        run = nil
        draw()
    }

    @objc
    private func pressedShow() {
        begin()
    }

    @objc
    private func pressedDone() {
        dismiss(nil)
    }

    private func draw() {
        preview.show(
            OverlayModel(entries: PreviewEntries.make(chosenCount), selection: shownSelection),
            appearance: center.appearance
        )
    }
}
