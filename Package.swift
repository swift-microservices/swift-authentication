// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "swift-authentication",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Authentication",
            targets: ["Authentication"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-service-context.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "ServiceContextModule", package: "swift-service-context")
            ]
        ),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: [
                .target(name: "Authentication"),
                .product(name: "ServiceContextModule", package: "swift-service-context"),
            ]
        ),
    ]
)
