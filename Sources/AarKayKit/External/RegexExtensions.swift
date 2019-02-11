//
//  RegexExtensions.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 29/03/18.
//

import Foundation
import SharedKit

extension String {
    /// Appends the string inside the template after the location of regex match.
    ///
    /// - Parameters:
    ///   - template: The template.
    ///   - regex: The regex.
    /// - Returns: The appended string.
    public func append(template: String, regex: String) -> String {
        var string = template
        if let existingRange = template.range(of: regex, options: [.regularExpression]) {
            string = String(template[..<existingRange.lowerBound])
        }
        if let range = range(of: regex, options: [.regularExpression]) {
            string += String(self[range.lowerBound...])
        }
        return string
    }

    /// Merges the string inside the template using regex captured groups.
    ///
    /// - Parameters:
    ///   - template: The template.
    ///   - regex: The regex.
    /// - Returns: The merged string.
    /// - Throws: An `Error` if regex merge encouters an error.
    public func merge(template: String, regex: String) throws -> String {
        var template = template
        let blockGroups = try capturedGroups(regex: regex)
        var blocks = [String: String]()
        blockGroups.forEach { blocks[String(self[$0[1]])] = String(self[$0[2]]) }
        let templateBlockGroups = try template.capturedGroups(regex: regex)
        templateBlockGroups.reversed().forEach {
            let text = blocks[String(template[$0[1]])] ?? ""
            let replacableRange = $0[2]
            template = template.replacingCharacters(in: replacableRange, with: "")
            text.reversed().forEach {
                template.insert($0, at: replacableRange.lowerBound)
            }
        }
        return template
    }

    fileprivate func capturedGroups(regex: String) throws -> [[Range<String.Index>]] {
        let regex = try Try {
            try NSRegularExpression(pattern: regex, options: [])
        }.do { error in
            AarKayKitError.internalError(
                "Failed to construct NSRegularExpression with \(regex)",
                with: error
            )
        }

        let matches = regex.matches(
            in: self, options: [],
            range: NSRange(location: 0, length: count)
        )
        var results = [[Range<String.Index>]]()
        matches.forEach {
            var groups = [Range<String.Index>]()
            let lastRangeIndex = $0.numberOfRanges - 1
            guard lastRangeIndex >= 1 else { return }
            for i in 1 ... lastRangeIndex {
                let capturedGroupIndex = Range($0.range(at: i), in: self)!
                groups.append(capturedGroupIndex)
            }
            results.append(groups)
        }
        return results
    }
}
