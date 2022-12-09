import ProjectDescription

public enum Constants {

    internal enum Error: Swift.Error {
        case runNumberNotPresent
    }

    static let baseAppBundleIdentifier = "co.calico"

    public static let teamIdentifier = "2TE7AHNP9P"

    public static let iOSDeploymentTargetVersion = "13.0"
    public static let iOSdeploymentTarget: DeploymentTarget = .iOS(targetVersion: Constants.iOSDeploymentTargetVersion, devices: .iphone)

    public static let macOSDeploymentTargetVersion = "11.0"
    public static let macOSdeploymentTarget: DeploymentTarget = .macOS(targetVersion: Constants.macOSDeploymentTargetVersion)

    static let marketingVersion = "1.0"

    static var buildNumber: String {
        get throws {
            if Environment.ci.getBoolean(default: false) && Environment.githubActions.getBoolean(default: false) {
                guard let runNumber = Environment.githubRunNumber,
                      case .string(let value) = runNumber else {
                    throw Error.runNumberNotPresent
                }

                return value
            }

            return "1"
        }
    }
}
