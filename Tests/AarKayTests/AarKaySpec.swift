//
//  AarKaySpec.swift
//  AarKayTests
//
//  Created by RahulKatariya on 23/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKay

class AarKaySpec: QuickSpec {
    let aarkayUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(
            "me.rahulkatariya.AarKay",
            isDirectory: true
        )
    let fileManager = FileManager.default

    override func spec() {
        beforeEach {
            expect { () -> Void in
                if self.fileManager.fileExists(atPath: self.aarkayUrl.path) {
                    try self.fileManager.removeItem(at: self.aarkayUrl)
                }
            }.toNot(throwError())
        }

        afterEach {
            expect {
                try self.fileManager.removeItem(at: self.aarkayUrl)
            }.toNot(throwError())
        }

        describe("AarKaySpec") {
            it("should work without plugin") {
                let paths = [
                    ("AarKay/.aarkay", "project: AarKay"),
                    ("AarKay/AarKayData/Random/Directory/File1.Random.yml", "name: Rahul"),
                    ("AarKay/AarKayData/Random/Directory/File2.Random.yml", "name: RK"),
                    ("AarKay/AarKayTemplates/Random.txt.stencil", "{{ project }} - {{ name }}"),
                ]

                expect { () -> Void in
                    try paths.forEach { path, contents in
                        let pathUrl = self.aarkayUrl.appendingPathComponent(path)
                        try self.fileManager.createDirectory(
                            at: pathUrl.deletingLastPathComponent(),
                            withIntermediateDirectories: true,
                            attributes: nil
                        )
                        try contents.write(to: pathUrl, atomically: true, encoding: .utf8)
                    }

                    let options = AarKayOptions(
                        force: true,
                        verbose: true
                    )
                    AarKay(url: self.aarkayUrl, options: options).bootstrap()

                    let file1Url = self.aarkayUrl
                        .appendingPathComponent("Directory/File1.txt")
                    let contents1 = try String(contentsOf: file1Url)
                    expect(contents1) == "AarKay - Rahul"

                    let file2Url = self.aarkayUrl
                        .appendingPathComponent("Directory/File2.txt")
                    let contents2 = try String(contentsOf: file2Url)
                    expect(contents2) == "AarKay - RK"
                }.toNot(throwError())
            }

            it("should override global context") {
                let paths = [
                    ("AarKay/.aarkay", "project: AarKay"),
                    ("AarKay/AarKayData/Random/Directory/File.Random.yml", "project: Rahul\nname: RK"),
                    ("AarKay/AarKayTemplates/Random.txt.stencil", "{{ project }} - {{ name }}"),
                ]

                expect { () -> Void in
                    try paths.forEach { path, contents in
                        let pathUrl = self.aarkayUrl.appendingPathComponent(path)
                        try self.fileManager.createDirectory(
                            at: pathUrl.deletingLastPathComponent(),
                            withIntermediateDirectories: true,
                            attributes: nil
                        )
                        try contents.write(to: pathUrl, atomically: true, encoding: .utf8)
                    }

                    let options = AarKayOptions(
                        force: true,
                        verbose: true
                    )
                    AarKay(url: self.aarkayUrl, options: options).bootstrap()

                    let fileUrl = self.aarkayUrl
                        .appendingPathComponent("Directory/File.txt")
                    let contents = try String(contentsOf: fileUrl)
                    expect(contents) == "Rahul - RK"
                }.toNot(throwError())
            }
        }
    }
}
