//
//  Dependency.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 06/01/19.
//

import Foundation

/// Represents a plugin dependency for AarKay.
public struct Dependency: Equatable, Hashable {
    /// The dependency url.
    public let url: URL

    /// The dependency version.
    public let version: String

    /// The dependency targets.
    public let targets: [String]

    /// The version type.
    let versionType: VersionType

    /// Initializes the AarKay plugin dependency.
    ///
    /// - Parameter string: The string with url and version.
    /// - Throws: Parsing error.
    public init(string: String, targets: [String] = []) throws {
        let dep = string.components(separatedBy: .newlines)
        guard dep.count > 0 else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .invalidUrl(dependency: string)
            )
        }
        let urlVersion = dep[0]
        let comps = urlVersion.components(separatedBy: ",")
        guard comps.count == 2,
            let url = URL(string: comps[0].trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .invalidUrl(dependency: string)
            )
        }
        self.url = url
        self.version = comps[1].trimmingCharacters(in: .whitespacesAndNewlines)
        guard let versionType = VersionType(
            string: version
        ) else {
            throw AarKayError.aarkayFileParsingFailed(
                reason: AarKayError.AarKayFileParsingReason
                    .invalidVersion(dependency: string)
            )
        }
        self.versionType = versionType
        if !targets.isEmpty {
            self.targets = targets
        } else {
            var url = url
            if url.absoluteString.hasSuffix(".git") { url = url.deletingPathExtension() }
            self.targets = [url.lastPathComponent]
        }
    }

    /// - Returns: Returns the package dependency description for Package.swift.
    public func urlDescription() -> String {
        var path = url.absoluteString
        if path.hasPrefix("./") { path = "./." + path }
        return path
    }
}
