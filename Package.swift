// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBloc",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SwiftBloc",
            targets: ["SwiftBloc"]),
    ],
    dependencies: [
        // No external dependencies - using only Swift and Combine
    ],
    targets: [
        .target(
            name: "SwiftBloc",
            dependencies: []),
        .testTarget(
            name: "SwiftBlocTests",
            dependencies: ["SwiftBloc"]),
    ]
)
