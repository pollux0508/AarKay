// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AarKay",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        .library(name: "AarKay", targets: ["AarKay"]),
        .library(name: "AarKayKit", targets: ["AarKayKit"]),
        .library(name: "aarkay-plugin-aarkay", targets: ["aarkay-plugin-aarkay"]),
        .library(name: "AarKayRunnerKit", targets: ["AarKayRunnerKit"]),
        .library(name: "SharedKit", targets: ["SharedKit"]),
        .executable(name: "AarKayCLI", targets: ["AarKayCLI"]),
        .executable(name: "AarKayRunner", targets: ["AarKayRunner"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        /* ------------------------------------------------------ */
        /* >>> AarKayKit ---------------------------------------- */
        /* ------------------------------------------------------ */
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", .upToNextMajor(from: "2.5.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "2.0.0")),
        /* ------------------------------------------------------ */
        /* >>> AarKay ------------------------------------------- */
        /* ------------------------------------------------------ */
        .package(url: "https://github.com/jdhealy/PrettyColors.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", .upToNextMinor(from: "0.8.2")),
        /* ------------------------------------------------------ */
        /* >>> Runner ------------------------------------------- */
        /* ------------------------------------------------------ */
        .package(url: "https://github.com/thoughtbot/Curry.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Carthage/Commandant.git", .upToNextMinor(from: "0.17.0")),
        /* ------------------------------------------------------ */
        /* >>> Testing ------------------------------------------ */
        /* ------------------------------------------------------ */
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AarKay",
            dependencies: [
                "AarKayKit",
                "AarKayRunnerKit",
                "PrettyColors",
                "SwiftyTextTable",
            ]
        ),
        .target(
            name: "AarKayKit",
            dependencies: [
                "SharedKit",
                "StencilSwiftKit",
                "Yams",
            ]
        ),
        .target(
            name: "aarkay-plugin-aarkay",
            dependencies: [
                "AarKayKit",
            ],
            path: "Sources/AarKayPlugin"
        ),
        .target(
            name: "AarKayCLI",
            dependencies: [
                "aarkay-plugin-aarkay",
                "AarKay",
            ]
        ),
        .target(
            name: "AarKayRunner",
            dependencies: [
                "Commandant",
                "AarKayRunnerKit",
            ]
        ),
        .target(
            name: "AarKayRunnerKit",
            dependencies: [
                "SharedKit",
                "AarKayKit",
                "Curry",
            ]
        ),
        .target(
            name: "SharedKit",
            dependencies: []
        ),
        .testTarget(
            name: "AarKayTests",
            dependencies: [
                "AarKay",
                "Quick",
                "Nimble",
            ]
        ),
        .testTarget(
            name: "AarKayPluginTests",
            dependencies: [
                "aarkay-plugin-aarkay",
                "Quick",
                "Nimble",
            ]
        ),
        .testTarget(
            name: "AarKayKitTests",
            dependencies: [
                "AarKayKit",
                "Quick",
                "Nimble",
            ]
        ),
        .testTarget(
            name: "AarKayRunnerKitTests",
            dependencies: [
                "AarKayRunnerKit",
                "Quick",
                "Nimble",
            ]
        ),
        .testTarget(
            name: "SharedKitTests",
            dependencies: [
                "SharedKit",
                "Quick",
                "Nimble",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
