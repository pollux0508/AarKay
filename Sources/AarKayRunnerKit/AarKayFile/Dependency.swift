//
//  Dependency.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 06/01/19.
//

import Foundation

/// Represents a plugin dependency for AarKay.
public struct Dependency: Equatable, Hashable {
    /// The url of dependency.
    let url: URL

    /// The version type.
    let version: VersionType

    /// Initializes the AarKay plugin dependency.
    ///
    /// - Parameter string: The string with url and version.
    /// - Throws: Parsing error.
    public init(string: String) throws {
        let comps = string.components(separatedBy: ",")
        guard comps.count == 2,
            let url = URL(string: comps[0].trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .invalidUrl(dependency: string)
            )
        }
        self.url = url
        guard let version = VersionType(
            string: comps[1].trimmingCharacters(in: .whitespacesAndNewlines)
        ) else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .invalidVersion(dependency: string)
            )
        }
        self.version = version
    }

    /// - Returns: Returns the package dependency description for Package.swift.
    public func urlDescription() -> String {
        var path = url.absoluteString
        if path.hasPrefix("./") { path = "./." + path }
        return path
    }

    /// - Returns: Returns the name of the target for Package.swift.
    public func targetDescription() -> String {
        var url = self.url
        if url.absoluteString.hasSuffix(".git") { url = url.deletingPathExtension() }
        return url.lastPathComponent
    }
}
