// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavigationKit",
    platforms: [.iOS(.v16), .tvOS(.v16), .macOS(.v13), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(
            name: "NavigationKit",
            targets: ["NavigationKit"]
        )
    ],
    dependencies: [
        // swift-async-stream 3.x requires a Swift 6.4 toolchain, like this package.
        .package(url: "https://github.com/o-nnerb/swift-async-stream.git", from: "3.0.0")
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
