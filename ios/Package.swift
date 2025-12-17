// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Quietly",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Quietly",
            targets: ["Quietly"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Quietly",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]
        ),
    ]
)
