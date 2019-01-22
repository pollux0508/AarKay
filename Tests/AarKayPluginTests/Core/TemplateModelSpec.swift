//
//  TemplateModelSpec.swift
//  AarKayPluginTests
//
//  Created by RahulKatariya on 16/01/19.
//

import Foundation
import Nimble
import Quick
import Yams
@testable import AarKayPlugin

class TemplateModelSpec: QuickSpec {
    override func spec() {
        describe("TemplateModel") {
            it("should work") {
                expect { () -> Void in
                    let templateString = """
                    name: Template
                    properties:
                      - name|String
                      - type|String?
                      - version|Int!|1
                    computedProperties:
                      - arg|String?
                    """
                    let templateModel = try YAMLDecoder().decode(TemplateModel.self, from: templateString)
                    expect(templateModel.properties.count) == 3
                    expect(templateModel.requiredProperties?.count) == 1
                    expect(templateModel.allProperties?.count) == 4
                    expect(templateModel.requiredAllProperties?.count) == 1
                    expect(templateModel.baseProperties?.count) == 0
                    expect(templateModel.requiredBaseProperties?.count) == 0
                    expect(templateModel.computedProperties?.count) == 1
                }.toNot(throwError())
            }

            it("should throw error if name is missing") {
                expect { () -> Void in
                    let templateString = """
                    properties:
                      - name|String
                      - type|String?
                      - version|Int!|1
                    computedProperties:
                      - arg|String?
                    """
                    _ = try YAMLDecoder().decode(TemplateModel.self, from: templateString)
                }.to(throwError())
            }
        }
    }
}
