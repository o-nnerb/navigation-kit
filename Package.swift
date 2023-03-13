// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavigationKit",
    platforms: [.iOS(.v16), .tvOS(.v16), .macOS(.v13), .watchOS(.v9)],
    products: [
        .library(
            name: "NavigationKit",
            targets: ["NavigationKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NavigationKit",
            dependencies: []
        ),
        .testTarget(
            name: "NavigationKitTests",
            dependencies: ["NavigationKit"]
        )
    ]
)
