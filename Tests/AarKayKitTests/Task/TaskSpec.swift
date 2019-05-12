//
//  TaskSpec.swift
//  AarKay
//
//  Created by RahulKatariya on 06/05/19.
//

import Foundation
import Nimble
import Quick
@testable import AarKayKit

class TaskSpec: QuickSpec {
    override func spec() {
        describe("Task") {
            it("should execute") {
                var output = ""
                _ = Task("/bin/echo", arguments: ["foobar"])
                    .run { o in output += o }
                expect(output) == "foobar\n"
            }
        }
    }
}
