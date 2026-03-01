// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Float",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        .library(name: "Float", targets: ["Float"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Float",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ],
            path: "Float"
        ),
        .testTarget(name: "FloatTests", dependencies: ["Float"], path: "FloatTests"),
    ]
)
