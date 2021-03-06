//
//  NameTypeValueSpec.swift
//  AarKayPluginTests
//
//  Created by RahulKatariya on 21/08/18.
//

import Foundation
import Nimble
import Quick
@testable import aarkay_plugin_aarkay

class NameTypeValueSpec: QuickSpec {
    override func spec() {
        describe("NameTypeValue") {
            it("should work for known types") {
                expect { () -> Void in
                    let string = "1|2|someString|||10.01|discardable"
                    let names = ["bool", "int", "string", "string?", "double?", "float"]
                    let types = ["Bool", "Int", "String", "String?", "Double?", "Float"]
                    let ntv = try NameTypeValue(
                        names: names,
                        types: types,
                        value: string
                    ).toDictionary()

                    expect(ntv["bool"] as? Bool).to(equal(true))
                    expect(ntv["int"] as? Int).to(equal(2))
                    expect(ntv["string"] as? String).to(equal("someString"))
                    expect(ntv["string?"] as? String).to(beEmpty())
                    expect(ntv["double?"]).to(beNil())
                    expect(ntv["float"] as? Float).to(equal(10.01))
                }.toNot(throwError())
            }

            it("should throw error for unknown types") {
                expect { () -> Void in
                    let string = "1||someString|fail"
                    let names = ["bool", "int", "string", "fail"]
                    let types = ["Bool", "Int?", "String", "Unknown"]
                    let ntv = try NameTypeValue(
                        names: names,
                        types: types,
                        value: string
                    ).toDictionary()

                    expect(ntv["bool"] as? Bool).to(equal(true))
                    expect(ntv["int"]).to(beNil())
                    expect(ntv["string"] as? String).to(equal("someString"))
                }.to(
                    throwError(
                        NameTypeValueError.invalidTransformation(
                            type: "Unknown", value: "fail"
                        )
                    )
                )
            }
        }
    }
}
