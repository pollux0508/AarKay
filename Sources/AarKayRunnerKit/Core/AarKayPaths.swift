//
//  AarKayPaths.default.swift
//  AarKay
//
//  Created by Rahul Katariya on 03/03/18.
//

import Foundation

/// A type encapsulating all paths used in AarKay.
public struct AarKayPaths {
    /// The location of AarKay.
    public let url: URL

    /// Initializes the default AarKayPaths with a base url.
    ///
    /// - Parameter url: The base url.
    public init(
        url: URL
    ) {
        self.url = url
    }

    /// Initializes the default AarKayPaths with location as home directory.
    public static let global = AarKayPaths(
        url: URL(
            fileURLWithPath: NSHomeDirectory(),
            isDirectory: true
        )
    )

    /// Initializes the default AarKayPaths with location as current directory.
    public static let local = AarKayPaths(
        url: URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
    )

    /// Creates the url for the root directory of `AarKay`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func aarkayPath() -> URL {
        return url
            .appendingPathComponent("AarKay", isDirectory: true)
    }

    /// Creates the url for the runner directory of `AarKay`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func runnerPath() -> URL {
        return aarkayPath()
            .appendingPathComponent("AarKayRunner", isDirectory: true)
    }

    /// Creates the url for the build path of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func buildPath() -> URL {
        return runnerPath()
            .appendingPathComponent(".build", isDirectory: true)
    }

    /// Creates the url for the `AarKayRunner` executable.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func cliPath() -> URL {
        return buildPath()
            .appendingPathComponent("debug/aarkay-cli")
    }

    /// Creates the url for the `main.swift` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func mainSwift() -> URL {
        return runnerPath()
            .appendingPathComponent("Sources/AarKayCLI/main.swift")
    }

    /// Creates the url of `Package.swift` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func packageSwift() -> URL {
        return runnerPath()
            .appendingPathComponent("Package.swift")
    }

    /// Creates the url of `Package.resolved` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func packageResolved() -> URL {
        return runnerPath()
            .appendingPathComponent("Package.resolved")
    }

    /// Creates the url of `.swift-version` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func swiftVersion() -> URL {
        return runnerPath()
            .appendingPathComponent(".swift-version")
    }

    /// Creates the url of `AarKayFile` file of `AarKayRunner`. This file is used to add user plugins.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func aarkayFile() -> URL {
        return aarkayPath()
            .appendingPathComponent("AarKayFile")
    }
}
