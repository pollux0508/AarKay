//
//  StringNTVTransformerSpec.swift
//  AarKayPluginTests
//
//  Created by RahulKatariya on 21/08/18.
//

import Foundation
import Nimble
import Quick
@testable import aarkay_plugin_aarkay

class StringNTVTransformerSpec: QuickSpec {
    override func spec() {
        describe("StringNTVTransformer") {
            it("works with String Type") {
                let value = StringTransformer(type: "String", value: "Hello, World!")?.value
                guard let expected = value as? String else {
                    fail("It should return the type as String")
                    return
                }

                expect(expected).to(equal("Hello, World!"))
            }
        }
    }
}
