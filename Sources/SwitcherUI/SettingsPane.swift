import AppKit

/// A settings tab's content: a view and the name it goes under. The forms are views rather
/// than controllers, so this is what gives one to the tab view.
@MainActor
final class SettingsPane: NSViewController {
    private let content: NSView

    init(content: NSView, title: String) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = content
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = content.fittingSize
    }
}
