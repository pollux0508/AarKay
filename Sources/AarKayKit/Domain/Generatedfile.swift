//
//  Generatedfile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 24/08/18.
//

import Foundation
import SharedKit

public struct Generatedfile {
    public let name: String
    public let ext: String?
    public let directory: String?
    public let override: Bool
    public let skip: Bool
    public let contents: String

    public var nameWithExt: String {
        if let ext = self.ext {
            return name + "." + ext
        } else {
            return name
        }
    }

    init(
        name: String,
        ext: String?,
        directory: String?,
        override: Bool,
        skip: Bool,
        contents: String
    ) {
        self.name = name.failIfEmpty()
        self.ext = ext.nilIfEmpty()
        self.directory = directory.nilIfEmpty()
        self.override = override
        self.skip = skip
        self.contents = contents
    }

    public func merge(_ currentString: String) -> String {
        var string = contents
        let blockRegexPattern = "\\n(.*)<aarkay (.*)>([\\s\\S]*?)\\n(.*)<\\/aarkay>(.*)\\n"
        if let blockGroups = currentString.capturedGroups(withRegex: blockRegexPattern),
            let templateBlockGroups = string.capturedGroups(withRegex: blockRegexPattern) {
            var blocks = [String: String]()
            blockGroups.forEach { blocks[String(currentString[$0[1]])] = String(currentString[$0[2]]) }
            templateBlockGroups.reversed().forEach {
                let text = blocks[String(contents[$0[1]])] ?? ""
                let replacableRange = $0[2]
                string = string.replacingCharacters(in: replacableRange, with: "")
                text.reversed().forEach {
                    string.insert($0, at: replacableRange.lowerBound)
                }
            }
        }

        let endRegexPattern = "\\n(.*) AarKayEnd"
        if let existingRange = string.range(of: endRegexPattern, options: [.regularExpression]) {
            string = String(string[..<existingRange.lowerBound])
        }
        if let range = currentString.range(of: endRegexPattern, options: [.regularExpression]) {
            string += String(currentString[range.lowerBound...])
        }
        return string
    }
}
