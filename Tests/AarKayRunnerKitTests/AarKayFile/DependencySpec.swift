//
//  DependencySpec.swift
//  AarKayRunnerKitTests
//
//  Created by RahulKatariya on 06/01/19.
//

import Nimble
import Quick
@testable import AarKayRunnerKit

class DependencySpec: QuickSpec {
    override func spec() {
        describe("Dependency") {
            it("should work with https and suffix git") {
                let depString = "https://github.com/RahulKatariya/AarKay.git, 0.0.0"
                guard let dep = try? Dependency(string: depString) else {
                    fail("Dep should not be nil"); return
                }
                expect(dep.urlDescription()) == "https://github.com/RahulKatariya/AarKay.git"
                expect(dep.versionType.description()) == ".exact(\"0.0.0\")"
                expect(dep.targets.count) == 1
                expect(dep.targets.first) == "AarKay"
            }

            it("should work with https and no git") {
                let depString = "https://github.com/RahulKatariya/AarKay, ~> 0.0.0"
                guard let dep = try? Dependency(string: depString) else {
                    fail("Dep should not be nil"); return
                }
                expect(dep.urlDescription()) == "https://github.com/RahulKatariya/AarKay"
                expect(dep.versionType.description()) == ".upToNextMinor(from: \"0.0.0\")"
                expect(dep.targets.count) == 1
                expect(dep.targets.first) == "AarKay"
            }

            it("should work with relative file url") {
                let depString = "./RahulKatariya/AarKay, > 0.0.0"
                guard let dep = try? Dependency(string: depString) else {
                    fail("Dep should not be nil"); return
                }
                expect(dep.urlDescription()) == "./../RahulKatariya/AarKay"
                expect(dep.versionType.description()) == ".upToNextMajor(from: \"0.0.0\")"
                expect(dep.targets.count) == 1
                expect(dep.targets.first) == "AarKay"
            }

            it("should work with absolute file url") {
                let depString = "/Users/RahulKatariya/AarKay, 0.0.0"
                guard let dep = try? Dependency(string: depString) else {
                    fail("Dep should not be nil"); return
                }
                expect(dep.urlDescription()) == "/Users/RahulKatariya/AarKay"
                expect(dep.versionType.description()) == ".exact(\"0.0.0\")"
                expect(dep.targets.count) == 1
                expect(dep.targets.first) == "AarKay"
            }

            it("should fail without version") {
                let depString = "/Users/RahulKatariya/AarKay"
                let dep = try? Dependency(string: depString)
                expect(dep).to(beNil())
            }

            it("should fail with incorrect version") {
                let depString = "/Users/RahulKatariya/AarKay, ~>0.0.0.0"
                let dep = try? Dependency(string: depString)
                expect(dep).to(beNil())
            }
        }
    }
}
