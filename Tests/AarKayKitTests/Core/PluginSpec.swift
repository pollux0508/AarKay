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
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("me.rahulkatariya.AarKay/\(UUID().uuidString)")
    let fileManager = FileManager.default

    override func spec() {
        describe("Plugin") {
            beforeEach {
                expect {
                    try self.fileManager.createDirectory(
                        at: self.url.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                }.toNot(throwError())
            }

            afterEach {
                expect { () -> Void in
                    try self.fileManager.removeItem(
                        at: self.url.deletingLastPathComponent()
                    )
                    expect(
                        self.fileManager.fileExists(atPath: self.url.path)
                    ) == false
                }.toNot(throwError())
            }

            expect { () -> Void in
                let plugin = try! Pluginfile(
                    name: "AarKayKitTests",
                    templates: nil,
                    globalTemplates: nil,
                    globalContext: nil
                )
                it("should generate files") {
                    expect { () -> Void in
                        let generatedFiles = try plugin.generate(
                            fileName: "File",
                            directory: "",
                            template: "Template",
                            input: .string("name: Template")
                        )
                        expect(generatedFiles.count) == 1
                    }.toNot(throwError())

                    expect { () -> Void in
                        try "- name: Template\n- name: Template2"
                            .write(to: self.url, atomically: true, encoding: .utf8)
                        _ = try plugin.generate(
                            fileName: "File",
                            directory: "",
                            template: "Template",
                            input: .url(self.url)
                        )
                    }.to(throwError())

                    expect { () -> Void in
                        try "- name: Template\n- name: Template2"
                            .write(to: self.url, atomically: true, encoding: .utf8)
                        let files = try plugin.generate(
                            fileName: "[]",
                            directory: "",
                            template: "Template",
                            input: .url(self.url)
                        )
                        expect(files.count) == 2
                    }.toNot(throwError())

                    expect { () -> Void in
                        try "- name: Template\n- noname: Template2"
                            .write(to: self.url, atomically: true, encoding: .utf8)
                        let files = try plugin.generate(
                            fileName: "[]",
                            directory: "",
                            template: "Template",
                            input: .url(self.url)
                        )
                        expect(files.count) == 2
                        expect(try? files.first?.get()).toNot(beNil())
                        expect(try? files.last?.get()).to(beNil())
                    }.toNot(throwError())

                    expect { () -> Void in
                        let files = try plugin.generate(
                            fileName: "[]",
                            directory: "",
                            template: "Template",
                            input: .string("""
                            - name: Template
                            - noname: Template2
                              _fn: Template2
                            """)
                        )
                        expect(files.count) == 2
                        expect(try? files.first?.get()).toNot(beNil())
                        expect(try? files.last?.get()).toNot(beNil())
                    }.toNot(throwError())
                }
            }.toNot(throwError())
        }
    }
}
