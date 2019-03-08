//
//  TemplatesSpec.swift
//  AarKayKitTests
//
//  Created by RahulKatariya on 26/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayKit

class TemplatesSpec: QuickSpec {
    let fileManager = FileManager.default

    override func spec() {
        describe("Templates") {
            it("should be not be nil if template exists") {
                expect { () -> Void in
                    let templates = try Templates(
                        fileManager: self.fileManager,
                        templates: [#file].map {
                            URL(fileURLWithPath: $0)
                                .deletingLastPathComponent()
                                .deletingLastPathComponent()
                                .deletingLastPathComponent()
                                .deletingLastPathComponent()
                                .appendingPathComponent(
                                    "AarKay/AarKayTemplates", isDirectory: true
                                )
                        }
                    )
                    expect(templates).toNot(beNil())

                    let template = try templates.getTemplatefile(for: "Template")
                    expect(template.count) == 1
                    expect(template.first?.template) == "Template.swift.stencil"
                    expect(template.first?.name) == "Template"
                    expect(template.first?.ext) == "swift"

                    let template2 = try templates.getTemplatefile(for: "Plugin")
                    expect(template2.count) == 1
                    expect(template2.first?.template) == "Plugin.swift.stencil"
                    expect(template2.first?.name) == "Plugin"
                    expect(template2.first?.ext) == "swift"
                }.toNot(throwError())
            }
        }
    }
}
