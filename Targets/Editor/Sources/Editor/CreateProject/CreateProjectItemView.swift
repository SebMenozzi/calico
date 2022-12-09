import AppKit
import Platform_macOS

struct CreateProjectItem {
    let index: Int
    let action: () -> Void
    let image: NSImage
    let title: String
    let description: String

    public init(index: Int, action: @escaping () -> Void, image: NSImage, title: String, description: String) {
        self.index = index
        self.action = action
        self.image = image
        self.title = title
        self.description = description
    }
}

final class CreateProjectItemView: PlatformView {

    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let descriptionLabelLayoutWidth: CGFloat = 350
        static let imageViewLeadingOffset: CGFloat = 16
        static let imageViewTopOffset: CGFloat = 16
        static let imageViewWidth: CGFloat = 32
        static let imageViewHeight: CGFloat = 32
        static let titleLabelTopOffset: CGFloat = 10
        static let titleLabelLeadingOffset: CGFloat = 20
        static let titleLabelTrailingOffset: CGFloat = 16
        static let descriptionLabelTrailingOffset: CGFloat = 16
        static let descriptionLabelTopOffset: CGFloat = 2
        static let descriptionLabelLeadingOffset: CGFloat = 20
        static let descriptionLabelBottomOffset: CGFloat = 10
        static let selectedColor: NSColor = NSColor(white: 0, alpha: 0.2)
    }
    
    var index: Int = 0
    
    var action: (() -> Void)?
    
    var item: CreateProjectItem? {
        didSet {
            guard let item = item else {
                return
            }
            
            index = item.index
            action = item.action
            imageView.image = item.image
            titleLabel.stringValue = item.title
            descriptionLabel.stringValue = item.description
        }
    }

    var isSelected = false {
        didSet {
            updateStyle()
        }
    }

    private let imageView = ImageView()..{
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let titleLabel = Label()..{
        $0.font = Font.title2(.bold)
        $0.cell?.usesSingleLineMode = false
        $0.cell?.wraps = true
        $0.cell?.lineBreakMode = .byWordWrapping
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var descriptionLabel = Label()..{
        $0.font = Font.body(.regular)
        $0.preferredMaxLayoutWidth = Constants.descriptionLabelLayoutWidth
        $0.cell?.usesSingleLineMode = false
        $0.cell?.wraps = true
        $0.cell?.lineBreakMode = .byWordWrapping
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.cornerRadius = Constants.cornerRadius

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.imageViewLeadingOffset),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.imageViewTopOffset),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleLabelTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.titleLabelLeadingOffset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.titleLabelTrailingOffset),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.descriptionLabelTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.descriptionLabelLeadingOffset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.descriptionLabelTrailingOffset),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.descriptionLabelBottomOffset)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        super.updateLayer()

        updateStyle()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        action?()
    }
    
    override func mouseEntered(with event: NSEvent) {
        titleLabel.textColor = Color.label
        descriptionLabel.textColor = Color.label
        
        NSCursor.pointingHand.set()
        
        layer?.backgroundColor = NSColor.systemBlue.cgColor
    }

    override func mouseExited(with event: NSEvent) {
        titleLabel.textColor = Color.label
        descriptionLabel.textColor = isSelected ? Color.label : Color.secondaryLabel
        
        NSCursor.arrow.set()
        
        layer?.backgroundColor = isSelected ? Constants.selectedColor.cgColor : .clear
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        for trackingArea in self.trackingAreas {
            removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        
        addTrackingArea(trackingArea)
    }
    
    private func updateStyle() {
        if isSelected {
            imageView.contentTintColor = Color.label
            titleLabel.textColor = Color.label
            descriptionLabel.textColor = Color.label
            layer?.backgroundColor = Constants.selectedColor.cgColor
        } else {
            imageView.contentTintColor = Color.secondaryLabel
            titleLabel.textColor = Color.label
            descriptionLabel.textColor = Color.secondaryLabel
            layer?.backgroundColor = .clear
        }
    }
}
