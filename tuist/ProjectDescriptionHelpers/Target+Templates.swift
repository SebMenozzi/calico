import ProjectDescription
import Foundation

extension Target {

    private static func _bundleIdentifier(for name: String) -> String {
        let name = name.replacingOccurrences(of: "_", with: "-")

        return Constants.baseAppBundleIdentifier + "." + name
    }

    // MARK: - App

    private static func createAppTarget(
        name: String,
        platform: ProjectDescription.Platform,
        product: ProjectDescription.Product,
        productName: String? = nil,
        bundleId: String,
        deploymentTarget: DeploymentTarget?,
        infoPlist: ProjectDescription.InfoPlist? = .default,
        sources: ProjectDescription.SourceFilesList? = nil,
        resources: ProjectDescription.ResourceFileElements? = nil,
        copyFiles: [ProjectDescription.CopyFilesAction]? = nil,
        headers: ProjectDescription.Headers? = nil,
        entitlements: ProjectDescription.Path? = nil,
        scripts: [ProjectDescription.TargetScript] = [],
        dependencies: [ProjectDescription.TargetDependency] = [],
        settings: ProjectDescription.Settings? = nil,
        coreDataModels: [ProjectDescription.CoreDataModel] = [],
        environment: [String : String] = [:],
        launchArguments: [ProjectDescription.LaunchArgument] = [],
        additionalFiles: [ProjectDescription.FileElement] = []
    ) -> Self {
        return self.init(
            name: name,
            platform: platform,
            product: product,
            productName: productName,
            bundleId: bundleId,
            deploymentTarget: deploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            copyFiles: copyFiles,
            headers: headers,
            entitlements: entitlements,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings,
            coreDataModels: coreDataModels,
            environment: environment,
            launchArguments: launchArguments,
            additionalFiles: additionalFiles
        )
    }

    public static func iOSApp(
        name: String,
        infoPlist: InfoPlist,
        sources: SourceFilesList,
        resources: ResourceFileElements,
        entitlements: Path,
        additionalSettings: ProjectDescription.Settings,
        dependencies: [TargetDependency]
    ) -> Self {
        return .createAppTarget(
            name: name,
            platform: .iOS,
            product: .app,
            productName: name,
            bundleId: Constants.baseAppBundleIdentifier,
            deploymentTarget: Constants.iOSdeploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: additionalSettings
        )
    }

    public static func macOSApp(
        name: String,
        infoPlist: InfoPlist,
        sources: SourceFilesList,
        resources: ResourceFileElements,
        entitlements: Path,
        additionalSettings: ProjectDescription.Settings,
        dependencies: [TargetDependency]
    ) -> Self {
        return .createAppTarget(
            name: name,
            platform: .macOS,
            product: .app,
            productName: name,
            bundleId: Constants.baseAppBundleIdentifier,
            deploymentTarget: Constants.macOSdeploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: additionalSettings
        )
    }

    // MARK: - Framework

    public static func createFrameworkTarget(
        name: String,
        platform: ProjectDescription.Platform,
        deploymentTarget: DeploymentTarget?,
        sources: SourceFilesList,
        headers: Headers? = nil,
        dependencies: [TargetDependency]
    ) -> Self {
        return self.init(
            name: name,
            platform: platform,
            product: .framework,
            bundleId: _bundleIdentifier(for: name),
            deploymentTarget: deploymentTarget,
            sources: sources,
            headers: headers,
            dependencies: dependencies
        )
    }

    public static func iOSFramework(
        name: String,
        sources: SourceFilesList,
        headers: Headers? = nil,
        dependencies: [TargetDependency]
    ) -> Self {
        return .createFrameworkTarget(
            name: name + "_iOS",
            platform: .iOS,
            deploymentTarget: Constants.iOSdeploymentTarget,
            sources: sources,
            headers: headers,
            dependencies: dependencies
        )
    }

    public static func macOSFramework(
        name: String,
        sources: SourceFilesList,
        headers: Headers? = nil,
        dependencies: [TargetDependency]
    ) -> Self {
        return .createFrameworkTarget(
            name: name + "_macOS",
            platform: .macOS,
            deploymentTarget: Constants.macOSdeploymentTarget,
            sources: sources,
            headers: headers,
            dependencies: dependencies
        )
    }
}
