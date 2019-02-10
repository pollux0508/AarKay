//
//  PluginSpec.swift
//  AarKayKitTests
//
//  Created by RahulKatariya on 26/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayKit

class PluginSpec: QuickSpec {
    override func spec() {
        describe("Plugin") {
            expect { () -> Void in
                let plugin = try Pluginfile(
                    name: "AarKayKitTests",
                    globalContext: nil,
                    globalTemplates: nil
                )
                it("should generate files") {
                    print(plugin.templateService.templates)
                    expect { () -> Void in
                        let generatedFiles = try plugin.generate(
                            fileName: "File",
                            directory: "",
                            template: "Template",
                            contents: "name: Template"
                        )
                        expect(generatedFiles.count) == 1
                    }.toNot(throwError())

                    expect { () -> Void in
                        _ = try plugin.generate(
                            fileName: "File",
                            directory: "",
                            template: "Template",
                            contents: "- name: Template\n- name: Template2"
                        )
                    }.to(throwError())

                    expect { () -> Void in
                        let files = try plugin.generate(
                            fileName: "[]",
                            directory: "",
                            template: "Template",
                            contents: "- name: Template\n- name: Template2"
                        )
                        expect(files.count) == 2
                    }.toNot(throwError())

                    expect { () -> Void in
                        let files = try plugin.generate(
                            fileName: "[]",
                            directory: "",
                            template: "Template",
                            contents: "- name: Template\n- noname: Template2"
                        )
                        expect(files.count) == 2
                        expect(files.first?.value).toNot(beNil())
                        expect(files.last?.value).to(beNil())
                    }.toNot(throwError())

                    expect { () -> Void in
                        let files = try plugin.generate(
                            fileName: "[]",
                            directory: "",
                            template: "Template",
                            contents: """
                            - name: Template
                            - noname: Template2
                              _fn: Template2
                            """
                        )
                        expect(files.count) == 2
                        expect(files.first?.value).toNot(beNil())
                        expect(files.last?.value).toNot(beNil())
                    }.toNot(throwError())
                }
            }.toNot(throwError())
        }
    }
}
