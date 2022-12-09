import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
    swiftPackageManager: .init(TargetDependency.SPMDependency.allCases),
    platforms: [.iOS, .macOS]
)
