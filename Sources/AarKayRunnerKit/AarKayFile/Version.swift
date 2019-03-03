//
//  Version.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 06/01/19.
//

import Foundation

/// A semantic version.
/// - Note: See <http://semver.org/>
struct Version: Equatable, Hashable {
    /// The major version.
    let major: Int

    /// The minor version.
    let minor: Int

    /// The patch version.
    let patch: Int

    /// Initializes a version from a string.
    ///
    /// - Parameter string: The string representing a version.
    init?(string: String) {
        let components = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: ".")
        guard components.count == 3,
            let major = Int(components[0]),
            let minor = Int(components[1]),
            let patch = Int(components[2]) else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// - Returns: The string description of the version.
    func description() -> String {
        return "\(major).\(minor).\(patch)"
    }
}
