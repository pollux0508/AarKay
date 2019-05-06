//
//  AarKayFile.swift
//  AarKayRunner
//
//  Created by RahulKatariya on 04/01/19.
//

import Foundation
import SharedKit

/// Represents the AarKayFile, which is a specification of a project's plugin dependencies.
public struct AarKayFile: Equatable, Hashable {
    /// Any dependency that starts this character is skipped.
    static let commentIndicator = "#"

    /// The dependencies listed in the AarKayFile.
    public let dependencies: [Dependency]

    /// Initializes the AarKayFile with all its plugin dependencies.
    ///
    /// - Parameter
    ///   - url: The location of AarKayFile.
    ///   - fileManager: The file manager.
    /// - Throws: Errors related to reading AarKayFile.
    public init(url: URL, fileManager: FileManager) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason.missingFile(url: url)
            )
        }
        let contents = try Try {
            try String(contentsOf: url)
        }.do { error in
            AarKayError.internalError(
                "Failed to fetch contents of \(url)", with: error
            )
        }
        let lines = contents.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !lines.isEmpty else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .missingAarKayDependency(url: url)
            )
        }
        // TODO: - Optmization
        var urlVersionRanges: [Int: [Int]] = [:]
        for (index, element) in lines.enumerated() {
            if !element.trimmingCharacters(in: CharacterSet(charactersIn: " #")).hasPrefix("-") {
                urlVersionRanges[index] = []
            } else {
                urlVersionRanges[urlVersionRanges.keys.sorted().last!]!.append(index)
            }
        }
        self.dependencies = try urlVersionRanges
            .filter { key, _ -> Bool in
                !lines[key].trimmingCharacters(in: .whitespaces)
                    .hasPrefix(AarKayFile.commentIndicator)
            }
            .sorted { $0.key < $1.key }
            .map { (key, value) -> Dependency in
                let dep = lines[key]
                let targets = value
                    .map { lines[$0] }
                    .filter {
                        !$0.trimmingCharacters(in: .whitespaces)
                            .hasPrefix(AarKayFile.commentIndicator)
                    }
                    .map {
                        $0.replacingOccurrences(
                            of: "\\s?-\\s*",
                            with: "",
                            options: [.regularExpression]
                        )
                    }
                return try Dependency(string: dep, targets: targets)
            }
        let allTargets = dependencies
            .map { $0.targets }
            .flatMap { $0 }
        let hasAarKay = allTargets.contains("AarKay")
        guard hasAarKay else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .missingAarKayDependency(url: url)
            )
        }
    }
}
