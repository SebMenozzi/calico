import ProjectDescription
import Foundation

internal extension SettingsDictionary {

    func applicationExtensionAPIOnly(_ value: Bool) -> Self {
        return merging(["APPLICATION_EXTENSION_API_ONLY": .init(booleanLiteral: value)])
    }

    func disableObjectiveCHeader() -> Self {
        return merging([
            "SWIFT_INSTALL_OBJC_HEADER": false,
            "SWIFT_OBJC_INTERFACE_HEADER_NAME": ""
        ])
    }

    func enableModuleDefinition(moduleName: String) -> Self {
        return merging([
            "DEFINES_MODULE": true,
            "PRODUCT_MODULE_NAME": .init(stringLiteral: moduleName)
        ])
    }

    func insertSwiftIntoLibrarySearchPaths() -> Self {
        let toolchainDirectory = "$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/"

        return merging([
            "LIBRARY_SEARCH_PATHS": .array([
                "$(inherited)",
                "$(SDKROOT)/usr/lib/swift",
                "$(SDK_DIR)/usr/lib/swift",
                toolchainDirectory
            ])
        ])
    }

    func linkerFlagsForFramework(libraryName: String?) -> Self {
        guard let libraryName = libraryName else {
            return self
        }

        let archiveName = "lib" + libraryName + ".a"

        let usrLibPath = "$(SDK_DIR)/usr/lib"

        let swiftPath = usrLibPath.appending("/swift")

        let toolchainDirectory = "$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/"

        let flags = [
            "$(inherited)",
            ["-Wl", "-force_load", "$(BUILT_PRODUCTS_DIR)/" + archiveName].joined(separator: ","),
            ["-Wl", "-add_ast_path", "$(BUILT_PRODUCTS_DIR)/" + libraryName + ".swiftmodule"].joined(separator: ","),
            ["-Wl", "-rpath", swiftPath].joined(separator: ","),
            ["-L", usrLibPath].joined(),
            ["-L", swiftPath].joined(),
            ["-L", toolchainDirectory].joined(),
            "-framework Foundation",
            "-framework UIKit",
            "-framework CoreLocation"
        ]

        return otherLinkerFlags(
            flags
        )
    }

    func disableAutomaticallyLinkingSwiftConcurrency() -> Self {
        return self
        // return otherSwiftFlags("$(inherited)", "-disable-autolinking-runtime-compatibility-concurrency")
    }

    func iOSDeploymentTargetVersion(_ version: String) -> Self {
        return merging(["IPHONEOS_DEPLOYMENT_TARGET": .string(version)])
    }

    func enableMetalFastMath() -> Self {
        return merging(["MTL_FAST_MATH": true])
    }

    func disableInfoPlistGeneration() -> Self {
        return merging(["GENERATE_INFOPLIST_FILE": false])
    }

    func disableSwiftLocalizableStringsExtraction() -> Self {
        return merging(["SWIFT_EMIT_LOC_STRINGS": false])
    }
}

public extension SettingsDictionary {

    func otherMetalCompilerFlags(_ flags: String...) -> Self {
        return merging(["MTL_COMPILER_FLAGS": .array(["$(inherited)"] + flags)])
    }

    func otherMetalLinkerFlags(_ flags: String...) -> Self {
            return merging(["MTLLINKER_FLAGS": .array(["$(inherited)"] + flags)])
    }
}

public extension Settings {

    static func defaultProjectSettings() -> Self {
        return defaultProjectSettings(appending: [:])
    }

    static func defaultProjectSettings(appending base: SettingsDictionary) -> Self {
        let baseSettings: SettingsDictionary = base
            .automaticCodeSigning(devTeam: Constants.teamIdentifier)
            .marketingVersion(Constants.marketingVersion)
            .currentProjectVersion(try! Constants.buildNumber)
            .enableMetalFastMath()
            .disableInfoPlistGeneration()
            .disableSwiftLocalizableStringsExtraction()

        return .settings(
            base: baseSettings,
            debug: [:],
            release: [:],
            defaultSettings: .recommended
        )
    }
}

internal extension Settings {

    static func _baseSwiftLibrarySettings(moduleName: String, isExtensionSafe: Bool) -> Settings {
        let settings = SettingsDictionary()
            .applicationExtensionAPIOnly(isExtensionSafe)
            .disableObjectiveCHeader()
            .enableModuleDefinition(moduleName: moduleName)
            .disableAutomaticallyLinkingSwiftConcurrency()

        return .settings(base: settings)
    }

    static func _baseFrameworkSettings(
        moduleName: String,
        isExtensionSafe: Bool,
        libraryName: String?
    ) -> Settings {
        let settings = SettingsDictionary()
            .applicationExtensionAPIOnly(isExtensionSafe)
            .disableObjectiveCHeader()
            .enableModuleDefinition(moduleName: moduleName)

        return .settings(base: settings)
    }
}
