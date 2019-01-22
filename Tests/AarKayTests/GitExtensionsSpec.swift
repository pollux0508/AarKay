//
//  GitExtensionsSpec.swift
//  AarKayTests
//
//  Created by RahulKatariya on 16/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKay

class GitExtensionsSpec: QuickSpec {
    override func spec() {
        let fileManager = FileManager.default
        let fixturesUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(
                "me.rahulkatariya.AarKay",
                isDirectory: true
            )

        beforeEach {
            try? fileManager.removeItem(at: fixturesUrl)
            expect(fileManager.fileExists(atPath: fixturesUrl.path)) == false
            expect { () -> Void in
                try fileManager.createDirectory(
                    at: fixturesUrl,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                expect(fileManager.fileExists(atPath: fixturesUrl.path)) == true
            }.toNot(throwError())
        }

        afterEach {
            expect { () -> Void in
                try fileManager.removeItem(at: fixturesUrl)
                expect(fileManager.fileExists(atPath: fixturesUrl.path)) == false
            }.toNot(throwError())
        }

        describe("Git Extensions") {
            context("empty directory") {
                it("should not be dirty") {
                    expect { () -> Void in
                        let isDirty = try fileManager.git.isDirty(url: fixturesUrl)
                        expect(isDirty) == false
                    }.toNot(throwError())
                }
            }

            context("non empty directory") {
                it("should be dirty") {
                    let fileUrl = fixturesUrl.appendingPathComponent("Folder/File.txt")
                    try? fileManager.createDirectory(
                        at: fileUrl.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    fileManager.createFile(
                        atPath: fileUrl.path,
                        contents: Data(),
                        attributes: nil
                    )
                    expect { () -> Void in
                        let isDirty = try fileManager.git.isDirty(url: fixturesUrl)
                        expect(isDirty) == true
                    }.toNot(throwError())
                }
            }

            context("git clean directory") {
                it("should not be dirty") {
                    let initStatus = BashProcess.run(
                        command: "git init",
                        url: fixturesUrl
                    )
                    expect(initStatus) == 0
                    let fileUrl = fixturesUrl.appendingPathComponent("Folder/File.txt")
                    try? fileManager.createDirectory(
                        at: fileUrl.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    fileManager.createFile(
                        atPath: fileUrl.path,
                        contents: Data(),
                        attributes: nil
                    )
                    let addStatus = BashProcess.run(
                        command: "git add -A .",
                        url: fixturesUrl
                    )
                    expect(addStatus) == 0
                    let commitStatus = BashProcess.run(
                        command: "git commit -m \"Initial Commit\"",
                        url: fixturesUrl
                    )
                    expect(commitStatus) == 0
                    expect { () -> Void in
                        let isDirty = try fileManager.git.isDirty(url: fixturesUrl)
                        expect(isDirty) == false
                    }.toNot(throwError())
                }
            }

            context("git untracked directory") {
                it("should be dirty") {
                    let initStatus = BashProcess.run(
                        command: "git init",
                        url: fixturesUrl
                    )
                    expect(initStatus) == 0
                    let fileUrl = fixturesUrl.appendingPathComponent("Folder/File.txt")
                    try? fileManager.createDirectory(
                        at: fileUrl.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    fileManager.createFile(
                        atPath: fileUrl.path,
                        contents: Data(),
                        attributes: nil
                    )
                    expect { () -> Void in
                        let isDirty = try fileManager.git.isDirty(url: fixturesUrl)
                        expect(isDirty) == true
                    }.toNot(throwError())
                }
            }

            context("git staged directory") {
                it("should be dirty") {
                    let initStatus = BashProcess.run(
                        command: "git init",
                        url: fixturesUrl
                    )
                    expect(initStatus) == 0
                    let fileUrl = fixturesUrl.appendingPathComponent("Folder/File.txt")
                    try? fileManager.createDirectory(
                        at: fileUrl.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    fileManager.createFile(
                        atPath: fileUrl.path,
                        contents: Data(),
                        attributes: nil
                    )
                    let addStatus = BashProcess.run(
                        command: "git add -A .",
                        url: fixturesUrl
                    )
                    expect(addStatus) == 0
                    expect { () -> Void in
                        let isDirty = try fileManager.git.isDirty(url: fixturesUrl)
                        expect(isDirty) == true
                    }.toNot(throwError())
                }
            }
        }
    }
}
