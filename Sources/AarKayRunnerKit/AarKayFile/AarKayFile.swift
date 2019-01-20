//
//  AarKayFile.swift
//  AarKayRunner
//
//  Created by RahulKatariya on 04/01/19.
//

import AarKayKit
import Foundation

/// Represents the plugin dependency file.
public struct AarKayFile {
    /// The dependencies
    public let dependencies: [Dependency]

    /// Initializes the dependencies.
    ///
    /// - Parameter contents: The string containing all dependencies seperated by newlines.
    /// - Throws: Parsing error.
    public init(url: URL, fileManager: FileManager) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason.missingFile(url)
            )
        }
        let contents = try Try {
            try String(contentsOf: url)
        }.catchMapError { error in
            AarKayError.internalError(
                "Failed to fetch contents of \(url)", with: error
            )
        }
        let lines = contents.components(separatedBy: .newlines).filter { !$0.isEmpty }
        dependencies = try lines.map { try Dependency(string: $0) }
        let hasAarKay = dependencies
            .map { $0.targetDescription() }
            .contains("\"AarKay\",")
        guard hasAarKay else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason.missingAarKayDependency(url)
            )
        }
    }
}
