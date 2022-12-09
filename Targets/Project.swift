import ProjectDescription
import ProjectDescriptionHelpers

func previewAppTarget() -> Target {
    let infoPlist: InfoPlist = .extendingDefault(with: [
        "UILaunchStoryboardName": "LaunchScreen.storyboard",
        "ITSAppUsesNonExemptEncryption": false,
        "UIRequiresFullScreen": true,
        "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait"
        ],
        "UIViewControllerBasedStatusBarAppearance": true,
        "CFBundleDisplayName": "Calico Preview",
        "CFBundleShortVersionString": "$(MARKETING_VERSION)",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
    ])

    let additionalSettings: SettingsDictionary = [:]
        .otherLinkerFlags([
            "$(inherited)",
            "-ObjC"
        ])

    let settings = Settings.defaultProjectSettings(appending: additionalSettings)

    return Target.iOSApp(
        name: "PreviewApp",
        infoPlist: infoPlist,
        sources: .paths(["Preview/Sources/**"]),
        resources: "Preview/Resources/**",
        entitlements: "Preview/App.entitlements",
        additionalSettings: settings,
        dependencies: TargetDependency.SPMDependency.allCases.map(TargetDependency.init)
    )
}

func editorAppTarget() -> Target {
    let infoPlist: InfoPlist = InfoPlist.dictionary([
        "CFBundleDisplayName": "Calico Editor",
        "CFBundleShortVersionString": "$(MARKETING_VERSION)",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
        "NSPrincipalClass": "NSApplication"
    ])

    let additionalSettings: SettingsDictionary = [:]
        .otherLinkerFlags([
            "$(inherited)",
            "-ObjC"
        ])

    let settings = Settings.defaultProjectSettings(appending: additionalSettings)

    return Target.macOSApp(
        name: "EditorApp",
        infoPlist: infoPlist,
        sources: .paths(["Editor/Sources/**"]),
        resources: "Editor/Resources/**",
        entitlements: "Editor/App.entitlements",
        additionalSettings: settings,
        dependencies: [
            .project(
                target: "Platform_macOS",
                path: .relativeToRoot("Modules/Platform")
            ),
            .project(
                target: "PeerTalk_macOS",
                path: .relativeToRoot("Modules/PeerTalk")
            )
        ] + TargetDependency.SPMDependency.allCases.map(TargetDependency.init)
    )
}

let project = Project.createProject(
    name: "Apps",
    packages: [],
    targets: [
        previewAppTarget(),
        editorAppTarget()
    ]
)
