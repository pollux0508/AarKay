//
//  AarKayFileSpec.swift
//  AarKayRunnerKitTests
//
//  Created by RahulKatariya on 07/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayRunnerKit

class AarKayFileSpec: QuickSpec {
    let aarkayfileUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("AarKayFile")
    let fileManager = FileManager.default

    override func spec() {
        afterEach {
            expect { () -> Void in
                try self.fileManager.removeItem(at: self.aarkayfileUrl)
                expect(
                    self.fileManager.fileExists(atPath: self.aarkayfileUrl.path)
                ) == false
            }.toNot(throwError())
        }
        describe("AarKayFile") {
            it("should work for correct format") {
                expect { () -> Void in
                    let aarkayFileContents = """
                    https://github.com/RahulKatariya/AarKay.git, b-master
                    ./../aarkay-plugin-test, ~> 0.0.0
                    /Users/Developer/Restofire/Restofire, > 1.1.0
                    """
                    try aarkayFileContents.write(
                        to: self.aarkayfileUrl, atomically: true, encoding: .utf8
                    )
                    let deps = try AarKayFile(
                        url: self.aarkayfileUrl,
                        fileManager: FileManager.default
                    ).dependencies
                    expect(deps.count) == 3

                    expect(deps[0].url.absoluteString) == "https://github.com/RahulKatariya/AarKay.git"
                    expect(deps[0].version) == .branch("master")

                    expect(deps[1].url.absoluteString) == "./../aarkay-plugin-test"
                    expect(deps[1].version) == .upToNextMinor("0.0.0")

                    expect(deps[2].url.absoluteString) == "/Users/Developer/Restofire/Restofire"
                    expect(deps[2].version) == .upToNextMajor("1.1.0")
                }.toNot(throwError())
            }

            it("should fail for incorrect format") {
                expect { () -> Void in
                    let aarkayFileContents = """
                    https://github.com/RahulKatariya/AarKay.git
                    ./../aarkay-plugin-test, ~> 0.0.0
                    """
                    try aarkayFileContents.write(
                        to: self.aarkayfileUrl, atomically: true, encoding: .utf8
                    )
                    _ = try AarKayFile(
                        url: self.aarkayfileUrl,
                        fileManager: FileManager.default
                    ).dependencies
                }.to(throwError())
            }
        }
    }
}
