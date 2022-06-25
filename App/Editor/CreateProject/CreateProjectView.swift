import AppKit

public final class CreateProjectView: View {
    
    private enum KeyCode: UInt16 {
        case down = 125
        case up = 126
        case enter = 36
    }
    
    static let itemsCount = 2

    private let stackView = NSStackView()..{
        $0.orientation = .vertical
        $0.alignment = .left
        $0.distribution = .fill
        $0.spacing = 0
    }
    
    public var selectedIndex: Int = 0 {
        didSet {
            stackView.arrangedSubviews
                .compactMap { $0 as? CreateProjectItemView }
                .forEach {
                    $0.isSelected = $0.index == selectedIndex
                }
        }
    }
    
    public override init() {
        super.init()
        
        addSubview(stackView)
        stackView.fillSuperview()
        
        let macOSProjectItemView = CreateProjectItemView()..{
            $0.item = CreateProjectItem(
                index: 0,
                action: {
                    print("macos")
                },
                image: NSImage(named: .computer)!,
                title: "macOS",
                description: "Create an experience targetting the macOS environnement, with the best performance available."
            )
            $0.isSelected = true
            $0.isUserInteractionsEnabled = true
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let iOSProjectItemView = CreateProjectItemView()..{
            $0.item = CreateProjectItem(
                index: 1,
                action: {
                    print("ios")
                },
                image: NSImage(named: .info)!,
                title: "iOS",
                description: "Create an experience targetting the iOS environnement, specifically adapated to get the best performance from mobiles."
            )
            $0.isUserInteractionsEnabled = true
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        stackView.addArrangedSubview(macOSProjectItemView)
        stackView.addArrangedSubview(iOSProjectItemView)

        NSLayoutConstraint.activate([
            macOSProjectItemView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            macOSProjectItemView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            iOSProjectItemView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            iOSProjectItemView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(with event: NSEvent) {
        let keyCode = KeyCode(rawValue: event.keyCode)
        
        switch keyCode {
        case .down:
            selectDown()
            
        case .up:
            selectUp()
            
        case .enter:
            stackView.arrangedSubviews
                .compactMap { $0 as? CreateProjectItemView }
                .forEach {
                    if $0.index == selectedIndex {
                        $0.action?()
                    }
                }
            
        default:
            break
        }
    }
    
    private func selectUp() {
        let upperbound = 0
        let nextIndex = selectedIndex - 1
        
        selectedIndex = nextIndex == upperbound - 1 ? Self.itemsCount - 1 : nextIndex
    }
    
    private func selectDown() {
        let upperbound = Self.itemsCount
        let nextIndex = selectedIndex + 1
        
        selectedIndex = nextIndex == upperbound ? 0 : nextIndex
    }
}
