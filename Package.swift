// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.macOS(.v12), .iOS(.v13)],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Networking",
            dependencies: []),
        
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]),
    ]
)
