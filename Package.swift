// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ios-production-templates",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "IOSProductionTemplates",
            targets: ["IOSProductionTemplates"]
        ),
    ],
    targets: [
        .target(
            name: "IOSProductionTemplates",
            dependencies: []
        ),
        .testTarget(
            name: "IOSProductionTemplatesTests",
            dependencies: ["IOSProductionTemplates"]
        ),
    ]
)
