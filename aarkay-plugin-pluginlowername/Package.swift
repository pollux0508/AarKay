// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AarKaypluginnamePlugin",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "AarKaypluginnameCLI",
            targets: ["AarKaypluginnameCLI"]
        ),
        .library(
            name: "aarkay-plugin-pluginlowername",
            targets: ["aarkay-plugin-pluginlowername"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/RahulKatariya/AarKay.git", .upToNextMinor(from: "0.8.3")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AarKaypluginnameCLI",
            dependencies: ["aarkay-plugin-pluginlowername", "AarKay"]
        ),
        .target(
            name: "aarkay-plugin-pluginlowername",
            dependencies: ["aarkay-plugin-aarkay"],
            path: "Sources/AarKaypluginnamePlugin"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
