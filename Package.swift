// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FlowNavigation",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "FlowNavigationTypes", targets: ["FlowNavigationTypes"]),
        .library(name: "FlowNavigationCore", targets: ["FlowNavigationCore"]),
        .library(name: "FlowNavigationUI", targets: ["FlowNavigationUI"]),
        .library(name: "FlowNavigationUIKit", targets: ["FlowNavigationUIKit"]),
        .library(name: "FlowNavigationPersistence", targets: ["FlowNavigationPersistence"]),
        .library(name: "FlowNavigationDeepLink", targets: ["FlowNavigationDeepLink"]),
        .library(name: "FlowNavigationGuard", targets: ["FlowNavigationGuard"]),
        .library(name: "FlowNavigationCoordinator", targets: ["FlowNavigationCoordinator"]),
        .library(name: "FlowNavigationEnvironment", targets: ["FlowNavigationEnvironment"]),
    ],
    targets: [

        .target(
            name: "FlowNavigationTypes",
            path: "Sources/FlowNavigationTypes",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationCore",
            dependencies: ["FlowNavigationTypes"],
            path: "Sources/FlowNavigationCore",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationUI",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore", "FlowNavigationGuard"],
            path: "Sources/FlowNavigationUI",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationUIKit",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore", "FlowNavigationCoordinator"],
            path: "Sources/FlowNavigationUIKit",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationPersistence",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore"],
            path: "Sources/FlowNavigationPersistence",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationDeepLink",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore"],
            path: "Sources/FlowNavigationDeepLink",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationGuard",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore"],
            path: "Sources/FlowNavigationGuard",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationCoordinator",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore", "FlowNavigationGuard"],
            path: "Sources/FlowNavigationCoordinator",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .target(
            name: "FlowNavigationEnvironment",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore", "FlowNavigationCoordinator"],
            path: "Sources/FlowNavigationEnvironment",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

        .testTarget(
            name: "FlowNavigationTests",
            dependencies: ["FlowNavigationTypes", "FlowNavigationCore"],
            path: "Tests/FlowNavigationTests"
        ),

        .testTarget(
            name: "FlowNavigationUITests",
            dependencies: ["FlowNavigationUI"],
            path: "Tests/FlowNavigationUITests"
        ),
    ]
)
