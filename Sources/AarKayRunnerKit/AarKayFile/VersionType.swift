//
//  VersionType.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 06/01/19.
//

import Foundation

/// Type that encapuslates the type of version with respect to Package.swift version spec.
///
/// - exact: Returned when the version string is exact.
/// - upToNextMajor: Returend when the version has prefix '>'.
/// - upToNextMinor: Returned when the version has prefix '~>' like (~> 1.0.0).
/// - branch: Returned when the version has prefix 'b-' like (b-master).
/// - revision: Returned when the version has prefix 'r-' like (r-32df72).
enum VersionType {
    case exact(String)
    case upToNextMajor(String)
    case upToNextMinor(String)
    case branch(String)
    case revision(String)

    /// Initializes the type of version.
    ///
    /// - Parameter string: The string representing the version
    /// - Throws: Parsing errors.
    init?(string: String) {
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("b-") {
            let startIndex = str.index(str.startIndex, offsetBy: 2)
            let version = String(str[startIndex...])
            guard !version.isEmpty else { return nil }
            self = .branch(version)
        } else if str.hasPrefix("r-") {
            let startIndex = str.index(str.startIndex, offsetBy: 2)
            let version = String(str[startIndex...])
            guard !version.isEmpty else { return nil }
            self = .revision(version)
        } else if str.hasPrefix("> ") {
            let startIndex = str.index(str.startIndex, offsetBy: 2)
            let versionString = String(str[startIndex...])
            guard let version = Version(string: versionString)?.description() else {
                return nil
            }
            self = .upToNextMajor(version)
        } else if str.hasPrefix("~> ") {
            let startIndex = str.index(str.startIndex, offsetBy: 3)
            let versionString = String(str[startIndex...])
            guard let version = Version(string: versionString)?.description() else {
                return nil
            }
            self = .upToNextMinor(version)
        } else if str.components(separatedBy: ".").count == 3 {
            guard let version = Version(string: str)?.description() else {
                return nil
            }
            self = .exact(version)
        } else {
            return nil
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
