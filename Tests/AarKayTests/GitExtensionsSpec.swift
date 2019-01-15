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
            .appendingPathComponent("fixtures")
        
        beforeEach {
            try? fileManager.removeItem(at: fixturesUrl)
            expect(fileManager.fileExists(atPath: fixturesUrl.path)) == false
            try? fileManager.createDirectory(
                at: fixturesUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
            expect(fileManager.fileExists(atPath: fixturesUrl.path)) == true
        }
        
        describe("Git Extensions") {
            context("empty directory") {
                it("should not be dirty") {
                    let isDirty = try? fileManager.git.isDirty(url: fixturesUrl)
                    expect(isDirty).toNot(beNil())
                    expect(isDirty!) == false
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
                    let isDirty = try? fileManager.git.isDirty(url: fixturesUrl)
                    expect(isDirty).toNot(beNil())
                    expect(isDirty!) == true
                }
            }
            
            context("git clean directory") {
                it("should not be dirty") {
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
                    let status = BashProcess.run(
                        command: "git init && git add . && git commit -m \"Initial Commit\"",
                        url: fixturesUrl
                    )
                    expect(status) == 0
                    let isDirty = try? fileManager.git.isDirty(url: fixturesUrl)
                    expect(isDirty).toNot(beNil())
                    expect(isDirty!) == false
                }
            }
            
            context("git untracked directory") {
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
                    let status = BashProcess.run(
                        command: "git init",
                        url: fixturesUrl
                    )
                    expect(status) == 0
                    let isDirty = try? fileManager.git.isDirty(url: fixturesUrl)
                    expect(isDirty).toNot(beNil())
                    expect(isDirty!) == true
                }
            }
            
            context("git staged directory") {
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
                    let status = BashProcess.run(
                        command: "git init && git add .",
                        url: fixturesUrl
                    )
                    expect(status) == 0
                    let isDirty = try? fileManager.git.isDirty(url: fixturesUrl)
                    expect(isDirty).toNot(beNil())
                    expect(isDirty!) == true
                }
            }
        }
    }
}
