//
//  DatafileSpec.swift
//  AarKayKitTests
//
//  Created by RahulKatariya on 26/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayKit

class DatafileSpec: QuickSpec {
    struct Context: Codable {
        let name: String
    }

    override func spec() {
        describe("Datafile") {
            it("should work") {
                let template = Template.nameStringExt(
                    "Template",
                    "Hi, My name is {{ name }}.",
                    "txt"
                )
                var df = Datafile(
                    fileName: "File",
                    directory: "Directory",
                    context: [:],
                    override: true,
                    skip: false,
                    template: template
                )
                let context = Context(name: "Rahul")
                expect { () -> Void in
                    expect(df.directory) == "Directory"

                    expect(df.context.isEmpty) == true

                    try df.setContext(context)
                    expect(df.context["name"] as? String) == "Rahul"

                    try df.setContext(["name": "AarKay"])
                    expect(df.context["name"] as? String) == "AarKay"

                    try df.setContext(context, with: ["name": "AarKay"])
                    expect(df.context["name"] as? String) == "AarKay"

                    try df.setContext(["name": "AarKay"], with: context)
                    expect(df.context["name"] as? String) == "Rahul"

                    expect(df.context["id"] as? String).to(beNil())
                    df.addContext(["id": "12345"])
                    expect(df.context["id"] as? String) == "12345"
                }.toNot(throwError())
            }
        }
    }
}
