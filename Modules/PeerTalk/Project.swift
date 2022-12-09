import ProjectDescription
import ProjectDescriptionHelpers

let frameworkName = "PeerTalk"

let iOSFrameworkTarget = Target.iOSFramework(
    name: frameworkName,
    sources: .paths(["Sources/**"]),
    headers: .allHeaders(
        from: "Sources/**",
        umbrella: "Sources/PeerTalk_iOS.h",
        private: "Sources/**"
    ),
    dependencies: []
)

let macOSFrameworkTarget = Target.macOSFramework(
    name: frameworkName,
    sources: .paths(["Sources/**"]),
    headers: .allHeaders(
        from: "Sources/**",
        umbrella: "Sources/PeerTalk_macOS.h",
        private: "Sources/**"
    ),
    dependencies: []
)

let project = Project.createProject(
    name: frameworkName,
    packages: [],
    targets: [iOSFrameworkTarget, macOSFrameworkTarget]
)
