//
//  TaskSpec.swift
//  AarKay
//
//  Created by RahulKatariya on 06/05/19.
//

import Foundation
import Nimble
import Quick
@testable import SharedKit

class TaskSpec: QuickSpec {
    override func spec() {
        describe("Task") {
            it("should execute") {
                var output = ""
                let _ = Task("/bin/echo", arguments: ["foobar"])
                    .run { o in output += o }
                expect(output) == "foobar\n"
            }
        }
    }
}
