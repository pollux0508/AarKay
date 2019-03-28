//
//  GeneratedfileSpec.swift
//  AarKayKitTests
//
//  Created by RahulKatariya on 25/01/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayKit

class GeneratedfileSpec: QuickSpec {
    override func spec() {
        describe("AarKayRegex") {
            describe("Append") {
                let ext = "txt"
                let templateContents = """
                "Hi, My name is {{ name }}."
                """
                let template = Template.nameStringExt(
                    "Template",
                    templateContents,
                    ext
                )
                let df = Datafile(
                    fileName: "File",
                    directory: "",
                    template: template,
                    globalContext: nil,
                    context: ["name": "Rahul"],
                    override: true,
                    skip: false
                )
                let contents = """
                Hi, My name is Rahul.
                """
                let gf = Generatedfile(datafile: df, ext: ext, contents: contents)

                it("should append after AarKayEnd") {
                    let string = """
                    I don't know my name.
                    AarKayEnd

                    This should persist.
                    """
                    expect { () -> Void in
                        let expected = """
                        Hi, My name is Rahul.
                        AarKayEnd

                        This should persist.
                        """
                        expect(try gf.merge(string)) == expected
                    }.toNot(throwError())
                }

                it("should append after // AarKayEnd") {
                    let string = """
                    I don't know my name.
                    // AarKayEnd

                    This should persist.
                    """
                    expect { () -> Void in
                        let expected = """
                        Hi, My name is Rahul.
                        // AarKayEnd

                        This should persist.
                        """
                        expect(try gf.merge(string)) == expected
                    }.toNot(throwError())
                }

                it("should append after // AarKayEnd ***") {
                    let string = """
                    I don't know my name.
                    // AarKayEnd ***

                    This should persist.
                    """
                    expect { () -> Void in
                        let expected = """
                        Hi, My name is Rahul.
                        // AarKayEnd ***

                        This should persist.
                        """
                        expect(try gf.merge(string)) == expected
                    }.toNot(throwError())
                }
            }

            describe("Merge") {
                let ext = "txt"
                let templateContents = """
                Hi, My name is {{ name }}.
                /// <aarkay id>
                /// Your custom logic goes here.
                /// </aarkay>
                /// <aarkay {{ name }}>
                /// Your custom logic goes here.
                /// </aarkay>
                """
                let template = Template.nameStringExt(
                    "Template",
                    templateContents,
                    ext
                )
                let df = Datafile(
                    fileName: "File",
                    directory: "",
                    template: template,
                    globalContext: nil,
                    context: ["name": "Rahul"],
                    override: true,
                    skip: false
                )
                let contents = """
                Hi, My name is Rahul.
                /// <aarkay id>
                /// Your custom logic goes here.
                /// </aarkay>
                /// <aarkay Rahul>
                /// Your custom logic goes here.
                /// </aarkay>
                """
                let gf = Generatedfile(datafile: df, ext: ext, contents: contents)

                it("should merge") {
                    let string = """
                    I don't know my name.
                    /// <aarkay id>
                    This line should persist
                    /// </aarkay>
                    /// <aarkay Rahul>
                    This line should persist
                    /// </aarkay>
                    """
                    expect { () -> Void in
                        let expected = """
                        Hi, My name is Rahul.
                        /// <aarkay id>
                        This line should persist
                        /// </aarkay>
                        /// <aarkay Rahul>
                        This line should persist
                        /// </aarkay>
                        """
                        expect(try gf.merge(string)) == expected
                    }.toNot(throwError())
                }
            }
        }
    }
}
