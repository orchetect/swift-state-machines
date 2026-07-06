// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-state-machines",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftStateMachines",
            targets: ["SwiftStateMachines"]
        )
    ],
    dependencies: [
        // External dependencies
        // (none)

        // Testing-only dependencies
        .package(url: "https://github.com/orchetect/swift-testing-extensions", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "SwiftStateMachines",
            dependencies: [
                // none
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
                // .enableExperimentalFeature("Lifetimes")
            ]
        ),
        .testTarget(
            name: "SwiftStateMachinesTests",
            dependencies: [
                "SwiftStateMachines",
                .product(name: "TestingExtensions", package: "swift-testing-extensions")
            ]
        )
    ]
)

#if canImport(Foundation) || canImport(CoreFoundation)
    #if canImport(Foundation)
        import class Foundation.ProcessInfo

        func getEnvironmentVar(_ name: String) -> String? {
            ProcessInfo.processInfo.environment[name]
        }

    #elseif canImport(CoreFoundation)
        import CoreFoundation

        func getEnvironmentVar(_ name: String) -> String? {
            guard let rawValue = getenv(name) else { return nil }
            return String(utf8String: rawValue)
        }
    #endif

    func isEnvironmentVarTrue(_ name: String) -> Bool {
        guard let value = getEnvironmentVar(name)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        else { return false }
        return ["true", "yes", "1"].contains(value.lowercased())
    }

    // MARK: - CI Pipeline

    if isEnvironmentVarTrue("GITHUB_ACTIONS") {
        for target in package.targets.filter(\.isTest) {
            if target.swiftSettings == nil { target.swiftSettings = [] }
            target.swiftSettings? += [.define("GITHUB_ACTIONS", .when(configuration: .debug))]
        }
    }
#endif
