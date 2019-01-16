//
//  VersionType.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 06/01/19.
//

import Foundation

/// Type that encapuslates the type of version with respect to Package.swift version spec.
enum VersionType {
    /// Represents the exact version (1.0.0).
    case exact(String)
    /// Represents the upToNextMajor version (> 1.0.0).
    case upToNextMajor(String)
    /// Represents the upToNextMinor version (~> 1.0.0).
    case upToNextMinor(String)
    /// Represents the git branch (b-master).
    case branch(String)
    /// Represents the git commit (r-32472hd2348dsdf).
    case revision(String)

    /// Initializes the type of version.
    ///
    /// - Parameter string: The string representing the version
    /// - Throws: Parsing errors.
    init(string: String) throws {
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("b-") {
            let startIndex = str.index(str.startIndex, offsetBy: 2)
            let version = String(str[startIndex...])
            guard !version.isEmpty else { throw AarKayError.parsingError }
            self = .branch(version)
        } else if str.hasPrefix("r-") {
            let startIndex = str.index(str.startIndex, offsetBy: 2)
            let version = String(str[startIndex...])
            guard !version.isEmpty else { throw AarKayError.parsingError }
            self = .revision(version)
        } else if str.hasPrefix("> ") {
            let startIndex = str.index(str.startIndex, offsetBy: 2)
            let versionString = String(str[startIndex...])
            let version = try Version(string: versionString).description()
            self = .upToNextMajor(version)
        } else if str.hasPrefix("~> ") {
            let startIndex = str.index(str.startIndex, offsetBy: 3)
            let versionString = String(str[startIndex...])
            let version = try Version(string: versionString).description()
            self = .upToNextMinor(version)
        } else if str.components(separatedBy: ".").count == 3 {
            let version = try Version(string: str).description()
            self = .exact(version)
        } else {
            throw AarKayError.parsingError
        }
    }

    /// - Returns: The description of the type of version to be used in Package.swift
    func description() -> String {
        switch self {
        case .exact(let version): return ".exact(\"\(version)\")"
        case .upToNextMajor(let version): return ".upToNextMajor(from: \"\(version)\")"
        case .upToNextMinor(let version): return ".upToNextMinor(from: \"\(version)\")"
        case .branch(let version): return ".branch(\"\(version)\")"
        case .revision(let version): return ".revision(\"\(version)\")"
        }
    }
}

extension VersionType: Equatable {}
