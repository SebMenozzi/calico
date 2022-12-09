import AppKit
import Platform_macOS

final class CreateProjectViewController: PlatformViewController {
    
    private enum Constants {
        static let welcomeContainerWidth: CGFloat = 350
        static let welcomeContainerHeight: CGFloat = 270
        static let welcomeIconImageViewSize: CGFloat = 150
        static let welcomeLabelTopOffset: CGFloat = 16
        static let versionLabelTopOffset: CGFloat = 4
        static let supportButtonTopOffset: CGFloat = 16
        static let headerLabelLeadingOffset: CGFloat = 16
        static let headerLabelTopOffset: CGFloat = 16
        static let descriptionLabelLeadingOffset: CGFloat = 16
        static let descriptionLabelTopOffset: CGFloat = 2
        static let lineHeight: CGFloat = 2
        static let lineTopOffset: CGFloat = 14
        static let createProjectViewOffset: CGFloat = 10
        static let supportURL: String = "https://google.com"
    }

    private let leftView = NSVisualEffectView()..{
        $0.material = .windowBackground
        $0.blendingMode = .behindWindow
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let rightView = NSVisualEffectView()..{
        $0.material = .sidebar
        $0.blendingMode = .behindWindow
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let welcomeContainerView = PlatformView()..{
        $0.layer = CALayer()
        $0.layer?.backgroundColor = NSColor.clear.cgColor
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let appIconImageView = ImageView(frame: .zero)..{
        //$0.image = NSImage(named: .applicationIcon)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let welcomeLabel = Label()..{
        $0.stringValue = "Welcome to Calico"
        $0.font = Font.largeTitle(.bold)
        $0.textColor = Color.label
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let versionLabel = Label()..{
        $0.stringValue = "Version 1.0"
        $0.font = Font.title3(.regular)
        $0.textColor = Color.secondaryLabel
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let supportButton = Button()..{
        $0.wantsLayer = true
        $0.layer?.backgroundColor = NSColor.clear.cgColor
        $0.isBordered = false
        $0.attributedTitle = NSAttributedString(
            string: "Support",
            attributes: [NSAttributedString.Key.foregroundColor: Color.secondaryLabel
        ])
        $0.font = Font.title3(.bold)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let createProjectView = CreateProjectView()..{
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let headerLabel = Label()..{
        $0.stringValue = "Create a project"
        $0.font = Font.title2(.bold)
        $0.textColor = Color.label
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var descriptionLabel = Label()..{
        $0.stringValue = "Select a suitable type for your project"
        $0.font = Font.body(.regular)
        $0.textColor = Color.secondaryLabel
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var lineView = PlatformView()..{
        $0.layer = CALayer()
        $0.layer?.backgroundColor = Color.label.withAlphaComponent(0.1).cgColor
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 846, height: 395))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        supportButton.action = #selector(onTap)
        
        view.addSubview(leftView)
        leftView.addSubview(welcomeContainerView)
        
        welcomeContainerView.addSubview(appIconImageView)
        welcomeContainerView.addSubview(welcomeLabel)
        welcomeContainerView.addSubview(versionLabel)
        welcomeContainerView.addSubview(supportButton)
        
        view.addSubview(rightView)
        rightView.addSubview(headerLabel)
        rightView.addSubview(descriptionLabel)
        rightView.addSubview(lineView)
        rightView.addSubview(createProjectView)
        
        NSLayoutConstraint.activate([
            leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftView.topAnchor.constraint(equalTo: view.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftView.widthAnchor.constraint(equalToConstant: Constants.welcomeContainerWidth),
            
            rightView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            rightView.topAnchor.constraint(equalTo: view.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            welcomeContainerView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
            welcomeContainerView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
            welcomeContainerView.widthAnchor.constraint(equalToConstant: Constants.welcomeContainerWidth),
            welcomeContainerView.heightAnchor.constraint(equalToConstant: Constants.welcomeContainerHeight),
            
            appIconImageView.topAnchor.constraint(equalTo: welcomeContainerView.topAnchor),
            appIconImageView.centerXAnchor.constraint(equalTo: welcomeContainerView.centerXAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: Constants.welcomeIconImageViewSize),
            appIconImageView.heightAnchor.constraint(equalToConstant: Constants.welcomeIconImageViewSize),
            
            welcomeLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: Constants.welcomeLabelTopOffset),
            welcomeLabel.centerXAnchor.constraint(equalTo: welcomeContainerView.centerXAnchor),
            
            versionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: Constants.versionLabelTopOffset),
            versionLabel.centerXAnchor.constraint(equalTo: welcomeContainerView.centerXAnchor),
            
            supportButton.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: Constants.supportButtonTopOffset),
            supportButton.centerXAnchor.constraint(equalTo: welcomeContainerView.centerXAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: rightView.topAnchor, constant: Constants.headerLabelTopOffset),
            headerLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: Constants.headerLabelLeadingOffset),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constants.descriptionLabelTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: Constants.descriptionLabelLeadingOffset),
            
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
            lineView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.lineTopOffset),
            
            createProjectView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: Constants.createProjectViewOffset),
            createProjectView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -Constants.createProjectViewOffset),
            createProjectView.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: Constants.createProjectViewOffset)
        ])
    }
    
    @objc private func onTap() {
        guard let url = URL(string: Constants.supportURL) else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }
}
