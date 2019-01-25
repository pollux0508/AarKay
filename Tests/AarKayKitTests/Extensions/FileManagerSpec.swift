//
//  FileManagerSpec.swift
//  AarKayKitTests
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayKit

class FileManagerSpec: QuickSpec {
    override func spec() {
        let fileManager = FileManager.default
        let fixturesUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(
                "me.rahulkatariya.AarKay",
                isDirectory: true
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
                let url = fixturesUrl.appendingPathComponent($0)
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

        describe("Temproray Directory") {
            it("should have 8 folders") {
                expect { () -> Void in
                    let files = try FileManager.default.subDirectories(at: [fixturesUrl])
                    expect(files.count) == 8
                }.toNot(throwError())
            }

            it("should have 4 files") {
                expect { () -> Void in
                    let files = try FileManager.default.subFiles(at: [fixturesUrl])
                    expect(files.count) == 4
                }.toNot(throwError())
            }
        }
    }
}
