import AppKit

final class EditorViewController: NSViewController {

    private var scrollView: NSScrollView!
    private var textView: NSTextView!

    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = NSScrollView(frame: .zero)
        scrollView.backgroundColor = NSColor.clear
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        scrollView.verticalRulerView = RulerView(scrollView: scrollView, orientation: .verticalRuler)

        view.addSubview(scrollView)
        scrollView.fillSuperview()

        textView = TextView(frame: .zero)
        textView.textContainerInset = NSSize(width: 0, height: 1)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.textColor = Color.label
        textView.backgroundColor = NSColor.red
        textView.typingAttributes = [NSAttributedString.Key.backgroundColor: Color.label]
        textView.delegate = self

        scrollView.contentView.addSubview(textView)
        textView.fillSuperview()
    }
}

extension EditorViewController: NSTextViewDelegate, NSTextDelegate {

    func textDidChange(_ notification: Notification) {
        print(notification)
    }
}
