//
//  UnknownNTVTransformerSpec.swift
//  AarKayPluginTests
//
//  Created by RahulKatariya on 21/08/18.
//

import Foundation
import Nimble
import Quick
@testable import aarkay_plugin_aarkay

class UnknownNTVTransformerSpec: QuickSpec {
    override func spec() {
        describe("UnknownNTVTransformer") {
            it("should return nil") {
                let value = StringTransformer(type: "Unknown", value: "Hello, World!")?.value
                expect(value).to(beNil())
            }
        }
    }
}
