//
//  Dependency.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 06/01/19.
//

import Foundation

/// Type that encapsulates a single dependency with respect to Package.swift.
public struct Dependency {
    /// The url of dependency.
    let url: URL
    /// The version type.
    let version: VersionType

    /// Initializes the dependency object.
    ///
    /// - Parameter string: The string with url and version.
    /// - Throws: Parsing error.
    public init(string: String) throws {
        let comps = string.components(separatedBy: ",")
        guard comps.count == 2,
            let url = URL(string: comps[0].trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw AarKayError.parsingError
        }
        self.url = url
        try self.version = VersionType(string: comps[1].trimmingCharacters(in: .whitespacesAndNewlines))
    }

    /// - Returns: Returns the package dependency description for Package.swift.
    public func packageDescription() -> String {
        var path = url.absoluteString
        if path.hasPrefix("./") { path = "./." + path }
        return ".package(url: \"\(path)\", \(version.description())),"
    }

    /// - Returns: Returns the name of the target.
    public func targetDescription() -> String {
        var url = self.url
        if url.absoluteString.hasSuffix(".git") { url = url.deletingPathExtension() }
        return "\"\(url.lastPathComponent)\","
    }
}
