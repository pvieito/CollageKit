// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CollageKit",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .executable(
            name: "CollageTool",
            targets: ["CollageTool"]
        ),
        .library(
            name: "CollageKit",
            targets: ["CollageKit"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:pvieito/CommandLineKit.git", .branch("master")),
        .package(url: "git@github.com:pvieito/LoggerKit.git", .branch("master")),
        .package(url: "git@github.com:pvieito/FoundationKit.git", .branch("master")),
        .package(url: "git@github.com:pvieito/CoreGraphicsKit.git", .branch("master")),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.12.0")
    ],
    targets: [
        .executableTarget(
            name: "CollageTool",
            dependencies: ["CollageKit", "LoggerKit", "CommandLineKit", "FoundationKit"],
            path: "CollageTool"
        ),
        .target(
            name: "CollageKit",
            dependencies: ["LoggerKit", "FoundationKit", "CoreGraphicsKit", "XMLCoder"],
            path: "CollageKit"
        ),
        .testTarget(
            name: "CollageKitTests",
            dependencies: ["CollageKit", "FoundationKit"],
            resources: [.process("Resources")]
        )
    ]
)
