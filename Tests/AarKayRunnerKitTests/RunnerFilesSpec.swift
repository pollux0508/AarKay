//
//  RunnerFilesSpec.swift
//  AarKayRunnerKitTests
//
//  Created by RahulKatariya on 16/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayRunnerKit

class RunnerFilesSpec: QuickSpec {
    override func spec() {
        describe("PackageSwift") {
            it("should work with AarKay dependency") {
                let actual = """
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
                    dependencies: [
                        .package(url: "https://github.com/RahulKatariya/AarKay.git", .exact("1.0.0")),
                    ],
                    targets: [
                        .target(
                            name: "aarkay-cli",
                            dependencies: [
                                "AarKayKit",
                                "aarkay-plugin-aarkay",
                                "AarKay",
                            ],
                            path: "Sources/AarKayCLI"),],
                    swiftLanguageVersions: [.v5]
                )
                """
                expect { () -> Void in
                    let dep = try Dependency(string: "https://github.com/RahulKatariya/AarKay.git, 1.0.0")
                    let packageSwift = PackageSwift.contents(deps: [dep])
                    expect(packageSwift).toNot(beNil())
                    expect(packageSwift) == actual
                }.toNot(throwError())
            }

            it("should work with AarKay and file dependency") {
                let actual = """
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
                    dependencies: [
                        .package(url: "https://github.com/RahulKatariya/AarKay.git", .exact("1.0.0")),
                        .package(url: "./../../aarkay-plugin-test", .upToNextMinor(from: "1.0.0")),
                    ],
                    targets: [
                        .target(
                            name: "aarkay-cli",
                            dependencies: [
                                "AarKayKit",
                                "aarkay-plugin-aarkay",
                                "AarKay",
                                "aarkay-plugin-test",
                            ],
                            path: "Sources/AarKayCLI"),],
                    swiftLanguageVersions: [.v5]
                )
                """
                expect { () -> Void in
                    let dep = try Dependency(string: "https://github.com/RahulKatariya/AarKay.git, 1.0.0")
                    let dep2 = try Dependency(string: "./../aarkay-plugin-test, ~> 1.0.0")
                    let packageSwift = PackageSwift.contents(deps: [dep, dep2])
                    expect(packageSwift).toNot(beNil())
                    expect(packageSwift) == actual
                }.toNot(throwError())
            }
        }
    }
}
