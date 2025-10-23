// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IAmMuslimShared",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "IAmMuslimShared",
            targets: ["IAmMuslimShared"]),
    ],
    targets: [
        .target(
            name: "IAmMuslimShared",
            dependencies: []),
        .testTarget(
            name: "IAmMuslimSharedTests",
            dependencies: ["IAmMuslimShared"]
        ),
    ]
)
