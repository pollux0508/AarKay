//
//  AarKayGlobalSpec.swift
//  AarKayTests
//
//  Created by RahulKatariya on 23/01/19.
//

import AarKayRunnerKit
import Foundation
import Nimble
import Quick
@testable import AarKay

class AarKayGlobalSpec: QuickSpec {
    let aarkayUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(
            "me.rahulkatariya.AarKay",
            isDirectory: true
        )
    let fileManager = FileManager.default
    let aarkayPaths = AarKayPaths.default

    override func spec() {
        describe("AarKayLocal") {
            let aarkayGlobal = AarKayGlobal(
                url: aarkayUrl,
                fileManager: fileManager
            )

            let globalContextUrl = self.aarkayUrl
                .appendingPathComponent("AarKay/.aarkay")

            beforeEach {
                try? self.fileManager.removeItem(at: self.aarkayUrl)
            }

            it("should be nil if there are no files") {
                expect { () -> Void in
                    let globalTemplatesPath = aarkayGlobal
                        .templatesUrl(aarkayPaths: self.aarkayPaths)
                    expect(globalTemplatesPath).toNot(beNil())
                    expect(try aarkayGlobal.context()).to(beNil())
                }.toNot(throwError())
            }

            it("should return the context") {
                let globalContextContents = """
                projectName: AarKay
                """
                expect { () -> Void in
                    try self.fileManager.createDirectory(
                        at: globalContextUrl.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try globalContextContents.write(
                        to: globalContextUrl, atomically: true, encoding: .utf8
                    )
                    let globalTemplatesPath = aarkayGlobal
                        .templatesUrl(aarkayPaths: self.aarkayPaths)
                    expect(globalTemplatesPath).toNot(beNil())
                    let projectName = try aarkayGlobal.context()?["projectName"] as? String
                    expect(projectName) == "AarKay"
                }.toNot(throwError())
            }

            it("should be empty") {
                expect { () -> Void in
                    try self.fileManager.createDirectory(
                        at: globalContextUrl.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try "".write(
                        to: globalContextUrl, atomically: true, encoding: .utf8
                    )
                    let globalTemplatesPath = aarkayGlobal
                        .templatesUrl(aarkayPaths: self.aarkayPaths)
                    expect(globalTemplatesPath).toNot(beNil())
                    expect(try aarkayGlobal.context()).to(beEmpty())
                }.toNot(throwError())
            }
        }

        describe("AarKayGlobal") {
            let aarkayGlobal = AarKayGlobal(
                url: URL(fileURLWithPath: NSHomeDirectory()),
                fileManager: fileManager
            )
            it("should be nil if global version of AarKay is used") {
                expect { () -> Void in
                    let globalTemplatesPath = aarkayGlobal
                        .templatesUrl(aarkayPaths: self.aarkayPaths)
                    expect(globalTemplatesPath).to(beNil())
                    expect(try aarkayGlobal.context()).to(beNil())
                }.toNot(throwError())
            }
        }
    }
}
