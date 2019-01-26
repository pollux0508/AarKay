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
                    directory: "",
                    context: [:],
                    override: true,
                    skip: false,
                    template: template
                )
                let context = Context(name: "Rahul")
                expect { () -> Void in
                    expect(df.context.isEmpty) == true
                    
                    expect(df.directory.isEmpty) == true
                    df.appendDirectory(nil)
                    expect(df.directory.isEmpty) == true
                    
                    df.appendDirectory("Directory")
                    expect(df.directory) == "Directory"
                    
                    df.setDirectory("Directory")
                    df.appendDirectory("Directory")
                    expect(df.directory) == "Directory/Directory"

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
