// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FlowNavigation",
    platforms: [
        .iOS(.v16)
    ],
    products: [
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
            name: "FlowNavigationCore",
            path: "Sources/FlowNavigationCore",
            swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
        ),

            .target(
                name: "FlowNavigationUI",
                dependencies: ["FlowNavigationCore","FlowNavigationGuard"],
                path: "Sources/FlowNavigationUI",
                swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
            ),

            .target(
                name: "FlowNavigationUIKit",
                dependencies: ["FlowNavigationCore", "FlowNavigationCoordinator"],
                path: "Sources/FlowNavigationUIKit",
                swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
            ),

            .target(
                name: "FlowNavigationPersistence",
                dependencies: ["FlowNavigationCore"],
                path: "Sources/FlowNavigationPersistence",
                swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
            ),

            .target(
                name: "FlowNavigationDeepLink",
                dependencies: ["FlowNavigationCore"],
                path: "Sources/FlowNavigationDeepLink",
                swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
            ),

            .target(
                name: "FlowNavigationGuard",
                dependencies: ["FlowNavigationCore"],
                path: "Sources/FlowNavigationGuard",
                swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
            ),

            .target(
                name: "FlowNavigationCoordinator",
                dependencies: ["FlowNavigationCore", "FlowNavigationGuard"],
                path: "Sources/FlowNavigationCoordinator",
                swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
            ),

            .target(
                name: "FlowNavigationEnvironment",
                dependencies: ["FlowNavigationCore", "FlowNavigationCoordinator"],
                path: "Sources/FlowNavigationEnvironment",
                swiftSettings: [.unsafeFlags(["-enable-library-evolution"])]
            ),

            .testTarget(
                name: "FlowNavigationTests",
                dependencies: ["FlowNavigationCore"],
                path: "Tests/FlowNavigationTests"
            ),

            .testTarget(
                name: "FlowNavigationUITests",
                dependencies: ["FlowNavigationUI"],
                path: "Tests/FlowNavigationUITests"
            ),
    ]
)
