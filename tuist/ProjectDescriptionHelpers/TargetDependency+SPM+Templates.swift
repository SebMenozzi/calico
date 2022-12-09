import ProjectDescription
import Foundation

public extension TargetDependency {
    
    enum SPMDependency: CaseIterable {
        /// [](https://github.com/ReactiveX/RxSwift)
        case rxSwift
        /// [](https://github.com/ReactiveX/RxSwift)
        case rxCocoa

        public var package: Package {
            switch self {
            case .rxSwift,
                    .rxCocoa:
                return .remote(url: "https://github.com/ReactiveX/RxSwift", requirement: .upToNextMajor(from: "6.5.0"))
            }
        }

        fileprivate var _productName: String {
            switch self {
            case .rxSwift:
                return "RxSwift"

            case .rxCocoa:
                return "RxCocoa"
            }
        }
    }
}

public extension TargetDependency {
    init(_ spmPackage: SPMDependency) {
        self = .external(name: spmPackage._productName)
    }
}

extension SwiftPackageManagerDependencies {
    public init(_ packages: [TargetDependency.SPMDependency]) {
        let uniquedPackages: [Package] = packages
            .map(\.package)
            .reduce(into: []) { accumulator, item in
            if !accumulator.contains(item) {
                accumulator.append(item)
            }
        }

        self.init(uniquedPackages)
    }
}
