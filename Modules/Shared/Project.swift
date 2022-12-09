import ProjectDescription
import ProjectDescriptionHelpers

let frameworkName = "Shared"

let iOSFrameworkTarget = Target.iOSFramework(
    name: frameworkName,
    sources: .paths(["Sources/**"]),
    dependencies: []
)

let macOSFrameworkTarget = Target.macOSFramework(
    name: frameworkName,
    sources: .paths(["Sources/**"]),
    dependencies: []
)

let project = Project.createProject(
    name: frameworkName,
    packages: [],
    targets: [iOSFrameworkTarget, macOSFrameworkTarget]
)
