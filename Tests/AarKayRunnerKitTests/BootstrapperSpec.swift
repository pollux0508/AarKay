//
//  BootstrapperSpec.swift
//  AarKayRunnerKitTests
//
//  Created by RahulKatariya on 16/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayRunnerKit

class BootstrapperSpec: QuickSpec {
    let fileManager = FileManager.default
    let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(
            "me.rahulkatariya.AarKay",
            isDirectory: true
        )

    override func spec() {
        let aarkayPaths = AarKayPaths(
            url: tempDir.appendingPathComponent("Local")
        )

        let bootstrapper = Bootstrapper(
            aarkayPaths: aarkayPaths,
            fileManager: fileManager
        )

        beforeEach {
            try? self.fileManager.removeItem(at: aarkayPaths.url)
            expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == false
        }

        afterEach {
            try? self.fileManager.removeItem(at: aarkayPaths.url)
            expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == false
        }

        describe("Bootstarpper") {
            context("when there is no AarKayFile") {
                it("should throw error") {
                    expect {
                        try bootstrapper.updatePackageSwift()
                    }.to(throwError())
                }
            }
            
            it("should bootstrap all directories") {
                expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == false
                expect { () -> Void in
                    try bootstrapper.bootstrap()
                }.toNot(throwError())
                expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == true
            }
            
            it("should throw error if AarKayFile is empty") {
                expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == false
                expect { () -> Void in
                    try bootstrapper.bootstrap()
                    try self.fileManager.removeItem(at: aarkayPaths.aarkayFile())
                    self.fileManager.createFile(
                        atPath: aarkayPaths.aarkayFile().path,
                        contents: Data(),
                        attributes: nil
                    )
                    try bootstrapper.updatePackageSwift()
                }.to(throwError())
                expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == true
            }
            
            it("should reset all directories") {
                expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == false
                expect { () -> Void in
                    try bootstrapper.bootstrap(force: true)
                    }.toNot(throwError())
                expect(self.fileManager.fileExists(atPath: aarkayPaths.url.path)) == true
                expect(self.fileManager.fileExists(atPath: aarkayPaths.aarkayPath().path)) == true
                expect(self.fileManager.fileExists(atPath: aarkayPaths.runnerPath().path)) == true
                expect(self.fileManager.fileExists(atPath: aarkayPaths.aarkayFile().path)) == true
                expect(self.fileManager.fileExists(atPath: aarkayPaths.packageSwift().path)) == true
                expect(self.fileManager.fileExists(atPath: aarkayPaths.mainSwift().path)) == true
                expect(self.fileManager.fileExists(atPath: aarkayPaths.swiftVersion().path)) == true
            }
        }
    }
}
