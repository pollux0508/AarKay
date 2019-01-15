//
//  DirTreeMirrorSpec.swift
//  AarKayTests
//
//  Created by RahulKatariya on 15/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKay

class DirTreeMirrorSpec: QuickSpec {
    override func spec() {
        let fixturesUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("fixtures")

        let sourceDir = "DirTree"
        let sourceUrl = fixturesUrl.appendingPathComponent(sourceDir)
        let destinationDir = "DirTreeMirror"
        let destinationUrl = fixturesUrl.appendingPathComponent(destinationDir)
        let fileManager = FileManager.default
        
        let dirTreeMirror = DirTreeMirror(
            sourceUrl: sourceUrl,
            destinationUrl: destinationUrl,
            fileManager: fileManager
        )
        
        let paths = [
            "Folder1/File.txt",
            "Folder2/Folder1/File.txt",
            "Folder3/Folder1/File.txt",
            "Folder3/Folder2/Folder1/File.txt",
        ]
        
        beforeEach {
            try? fileManager.removeItem(at: fixturesUrl)
            expect(fileManager.fileExists(atPath: fixturesUrl.path)) == false
            paths.forEach {
                let url = sourceUrl.appendingPathComponent($0)
                try? fileManager.createDirectory(
                    at: url.deletingLastPathComponent(),
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                fileManager.createFile(
                    atPath: url.path,
                    contents: Data(),
                    attributes: nil
                )
                expect(fileManager.fileExists(atPath: url.path)) == true
            }
        }
        
        afterEach {
            expect(fileManager.fileExists(atPath: fixturesUrl.path)) == true
            try? fileManager.removeItem(at: fixturesUrl)
            expect(fileManager.fileExists(atPath: fixturesUrl.path)) == false
        }
        
        describe("DirTreeMirror") {
            it("should work") {
                let tree = try! dirTreeMirror.bootstrap()
                    .sorted { $0.0.relativePath < $1.0.relativePath }
                expect(tree.count) == paths.count
                for (idx, item) in tree.enumerated() {
                    expect(item.0.baseURL!.lastPathComponent) == sourceDir
                    expect(item.0.relativePath) == paths[idx]
                    expect(item.1.baseURL!.lastPathComponent) == destinationDir
                    expect(item.1.relativePath) == paths[idx]
                }
            }
        }
    }
}
