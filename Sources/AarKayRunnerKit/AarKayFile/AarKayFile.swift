//
//  AarKayFile.swift
//  AarKayRunner
//
//  Created by RahulKatariya on 04/01/19.
//

import Foundation

/// Represents the plugin dependency file.
public struct AarKayFile {
    /// The dependencies
    public let dependencies: [Dependency]

    /// Initializes the dependencies.
    ///
    /// - Parameter contents: The string containing all dependencies seperated by newlines.
    /// - Throws: Parsing error.
    public init(contents: String) throws {
        let lines = contents.components(separatedBy: .newlines).filter { !$0.isEmpty }
        dependencies = try lines.map { try Dependency(string: $0) }
    }
}
