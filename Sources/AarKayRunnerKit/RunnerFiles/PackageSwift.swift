//
//  PackageSwift.swift
//  AarKayRunnerKit
//
//  Created by Rahul Katariya on 10/03/19.
//

import Foundation

/// Package.swift file for `AarKayRunner`.
class PackageSwift {
    /// The contents.
    static func contents(deps: [Dependency]) -> String {
        let packages = deps.reduce("") { (result, item) -> String in
            result + """
            \n        .package(url: \"\(item.urlDescription())\", \(item.versionType.description())),
            """
        }

        let dependencies = deps.reduce("") { (result, item) -> String in
            result + item.targets.reduce("") { (result, item) -> String in
                result + "\n                \"\(item)\","
            }
        }

        return """
        // swift-tools-version:5.0
        import PackageDescription
        import Foundation
        
        let package = Package(
            name: "AarKayRunner",
            platforms: [
                .macOS(.v10_12),
            ],
            products: [
                .executable(name: "aarkay-cli", targets: ["aarkay-cli"])],
            dependencies: [\(packages)
            ],
            targets: [
                .target(
                    name: "aarkay-cli",
                    dependencies: [
                        "AarKayKit",
                        "aarkay-plugin-aarkay",\(dependencies)
                    ],
                    path: "Sources/AarKayCLI"),],
            swiftLanguageVersions: [.v5]
        )
        """
    }
}
