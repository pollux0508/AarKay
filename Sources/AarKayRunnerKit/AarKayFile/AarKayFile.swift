//
//  AarKayFile.swift
//  AarKayRunner
//
//  Created by RahulKatariya on 04/01/19.
//

import Foundation

/// Represents the AarKayFile, which is a specification of a project's plugin dependencies.
public struct AarKayFile {
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
        var contents: String!
        do {
            contents = try String(contentsOf: url)
        } catch {
            throw AarKayError.internalError(
                "Failed to fetch contents of \(url)", with: error
            )
        }
        let lines = contents.components(separatedBy: .newlines).filter { !$0.isEmpty }
        dependencies = try lines.filter {
            $0.trimmingCharacters(in: .whitespaces).hasPrefix(
                AarKayFile.commentIndicator
            )
        }
        .map { try Dependency(string: $0) }
        let hasAarKay = dependencies
            .map { $0.targetDescription() }
            .contains("\"AarKay\",")
        guard hasAarKay else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .missingAarKayDependency(url: url)
            )
        }
    }
}
