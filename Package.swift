// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavigationKit",
    platforms: [.iOS(.v15), .tvOS(.v15), .macOS(.v12), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(
            name: "NavigationKit",
            targets: ["NavigationKit"]
        )
    ],
    dependencies: [
        // swift-async-stream 3.x requires a Swift 6.4 toolchain, like this package.
        .package(url: "https://github.com/o-nnerb/swift-async-stream.git", from: "3.0.1")
    ],
    targets: [
        .target(
            name: "NavigationKit",
            dependencies: [
                .product(name: "SwiftAsyncStream", package: "swift-async-stream")
            ]
        ),
        .testTarget(
            name: "NavigationKitTests",
            dependencies: ["NavigationKit"]
        ),
    ]
)
