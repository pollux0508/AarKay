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

    override func spec() {
        let aarkayPaths = AarKayPaths(
            globalUrl: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Global"),
            localUrl: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Local")
        )
        let bootstrapper = Bootstrapper(aarkayPaths: aarkayPaths)

        beforeEach {
            try? self.fileManager.removeItem(at: aarkayPaths.globalUrl)
            try? self.fileManager.removeItem(at: aarkayPaths.localUrl)
            expect(self.fileManager.fileExists(atPath: aarkayPaths.globalUrl.path)) == false
            expect(self.fileManager.fileExists(atPath: aarkayPaths.localUrl.path)) == false
        }

        afterEach {
            try? self.fileManager.removeItem(at: aarkayPaths.globalUrl)
            try? self.fileManager.removeItem(at: aarkayPaths.localUrl)
            expect(self.fileManager.fileExists(atPath: aarkayPaths.globalUrl.path)) == false
            expect(self.fileManager.fileExists(atPath: aarkayPaths.localUrl.path)) == false
        }

        [
            (true, aarkayPaths.globalUrl),
            (false, aarkayPaths.localUrl),
        ].forEach { global, url in
            describe("Bootstarpper") {
                context("when there is no AarKayFile") {
                    it("should throw error") {
                        expect {
                            try bootstrapper.updatePackageSwift(global: global)
                        }.to(throwError())
                    }
                }

                it("should bootstrap all directories") {
                    expect(self.fileManager.fileExists(atPath: url.path)) == false
                    expect { () -> Void in
                        try bootstrapper.bootstrap(global: global)
                        try bootstrapper.updatePackageSwift(global: global)
                    }.toNot(throwError())
                    expect(self.fileManager.fileExists(atPath: url.path)) == true
                }

                it("should throw error if AarKayFile is empty") {
                    expect(self.fileManager.fileExists(atPath: url.path)) == false
                    expect { () -> Void in
                        try bootstrapper.bootstrap(global: global)
                        try self.fileManager.removeItem(at: aarkayPaths.aarkayFile(global: global))
                        self.fileManager.createFile(
                            atPath: aarkayPaths.aarkayFile(global: global).path,
                            contents: Data(),
                            attributes: nil
                        )
                        try bootstrapper.updatePackageSwift(global: global)
                    }.to(throwError())
                    expect(self.fileManager.fileExists(atPath: url.path)) == true
                }

                it("should reset all directories") {
                    expect(self.fileManager.fileExists(atPath: url.path)) == false
                    expect { () -> Void in
                        try bootstrapper.bootstrap(global: global)
                        try bootstrapper.bootstrap(global: global, force: true)
                    }.toNot(throwError())
                    expect(self.fileManager.fileExists(atPath: url.path)) == true
                    expect(self.fileManager.fileExists(atPath: aarkayPaths.aarkayPath(global: global).path)) == true
                    expect(self.fileManager.fileExists(atPath: aarkayPaths.runnerPath(global: global).path)) == true
                    expect(self.fileManager.fileExists(atPath: aarkayPaths.aarkayFile(global: global).path)) == true
                    expect(self.fileManager.fileExists(atPath: aarkayPaths.packageSwift(global: global).path)) == true
                    expect(self.fileManager.fileExists(atPath: aarkayPaths.mainSwift(global: global).path)) == true
                    expect(self.fileManager.fileExists(atPath: aarkayPaths.swiftVersion(global: global).path)) == true
                }
            }
        }
    }
}
