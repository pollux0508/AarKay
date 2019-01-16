//
//  ArgModelSpec.swift
//  AarKayPluginTests
//
//  Created by RahulKatariya on 16/01/19.
//

import Foundation
import Nimble
import Quick
import Yams
@testable import AarKayPlugin

class ArgModelSpec: QuickSpec {
    override func spec() {
        describe("ArgModel") {
            it("should work with simple type") {
                expect { () -> Void in
                    let argString = "name|String"
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "String"
                    expect(argModel.swiftType) == "String"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == false
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == false
                    expect(argModel.isOptionalOrWrapped) == false
                }.toNot(throwError())
            }

            it("should work with optional type") {
                expect { () -> Void in
                    let argString = "name|String?"
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "String?"
                    expect(argModel.swiftType) == "String"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == false
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == true
                    expect(argModel.isOptionalOrWrapped) == true
                }.toNot(throwError())
            }

            it("should work with default value") {
                expect { () -> Void in
                    let argString = "name|String!|Rahul"
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "String!"
                    expect(argModel.swiftType) == "String"
                    expect(argModel.value) == "Rahul"
                    expect(argModel.isArray) == false
                    expect(argModel.isWrapped) == true
                    expect(argModel.isOptional) == false
                    expect(argModel.isOptionalOrWrapped) == true
                }.toNot(throwError())
            }

            it("should work with array type") {
                expect { () -> Void in
                    let argString = "name|[String]"
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "[String]"
                    expect(argModel.swiftType) == "[String]"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == true
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == false
                    expect(argModel.isOptionalOrWrapped) == false
                }.toNot(throwError())
            }

            it("should work with optional array type") {
                expect { () -> Void in
                    let argString = "name|[String]?"
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "[String]?"
                    expect(argModel.swiftType) == "[String]"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == true
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == true
                    expect(argModel.isOptionalOrWrapped) == true
                }.toNot(throwError())
            }

            it("should work with optional dictionary type") {
                expect { () -> Void in
                    let argString = "\"name|[String: String]\""
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "[String: String]"
                    expect(argModel.swiftType) == "[String: String]"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == false
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == false
                    expect(argModel.isOptionalOrWrapped) == false
                }.toNot(throwError())
            }

            it("should work with optional dictionary type") {
                expect { () -> Void in
                    let argString = "\"name|[String: String]?\""
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "[String: String]?"
                    expect(argModel.swiftType) == "[String: String]"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == false
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == true
                    expect(argModel.isOptionalOrWrapped) == true
                }.toNot(throwError())
            }

            it("should work with array dictionary type") {
                expect { () -> Void in
                    let argString = "\"name|[[String: String]]\""
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "[[String: String]]"
                    expect(argModel.swiftType) == "[[String: String]]"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == true
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == false
                    expect(argModel.isOptionalOrWrapped) == false
                }.toNot(throwError())
            }

            it("should work with 2d array type") {
                expect { () -> Void in
                    let argString = "\"name|[[String]]?\""
                    let argModel = try YAMLDecoder().decode(ArgModel.self, from: argString)
                    expect(argModel.name) == "name"
                    expect(argModel.type) == "[[String]]?"
                    expect(argModel.swiftType) == "[[String]]"
                    expect(argModel.value).to(beNil())
                    expect(argModel.isArray) == true
                    expect(argModel.isWrapped) == false
                    expect(argModel.isOptional) == true
                    expect(argModel.isOptionalOrWrapped) == true
                }.toNot(throwError())
            }
        }
    }
}
