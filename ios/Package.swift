// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Quietly",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Quietly",
            targets: ["Quietly"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Quietly",
            dependencies: []
        ),
    ]
)
