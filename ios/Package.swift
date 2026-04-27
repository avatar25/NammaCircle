// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NammaCircleDependencies",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "NammaCircleDependencies", targets: ["NammaCircleDependencies"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "NammaCircleDependencies",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
