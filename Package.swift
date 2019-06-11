// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CollageViewer",
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
        .package(path: "../LoggerKit"),
        .package(path: "../CommandLineKit"),
        .package(path: "../FoundationKit"),
        .package(path: "../CoreGraphicsKit"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "CollageTool",
            dependencies: ["CollageKit", "LoggerKit", "CommandLineKit", "FoundationKit"],
            path: "CollageTool"
        ),
        .target(
            name: "CollageKit",
            dependencies: ["LoggerKit", "FoundationKit", "CoreGraphicsKit", "SWXMLHash"],
            path: "CollageKit"
        )
    ]
)
