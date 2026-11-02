// swift-tools-version: 6.3
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
    dependencies: [
        // 2.1.4 supports Swift 6.2/6.3 toolchains, 3.x requires Swift 6.4. The API used here is identical in both.
        .package(url: "https://github.com/o-nnerb/swift-async-stream.git", "2.1.4"..<"4.0.0")
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
