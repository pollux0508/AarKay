//
//  AarKayPaths.default.swift
//  AarKay
//
//  Created by Rahul Katariya on 03/03/18.
//

import Foundation

public struct AarKayPaths {
    /// The global location of AarKay
    let globalUrl: URL
    /// The local location of AarKay
    let localUrl: URL

    /// Initializes the default AarKayPaths with global location as home directory and local location as current directory.
    public static let `default` = AarKayPaths(
        globalUrl: URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true),
        localUrl: URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    )

    /// Decides whether to use global directory or the local directory depending on the global flag.
    ///
    /// - Parameter global: Setting global to true will return the global directory otherwise local directory.
    /// - Returns: The created url.
    public func directoryPath(global: Bool = false) -> URL {
        return global ? globalUrl : localUrl
    }

    /// Creates the url for the root directory of `AarKay`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func aarkayPath(global: Bool = false) -> URL {
        return directoryPath(global: global).appendingPathComponent("AarKay", isDirectory: true)
    }

    /// Creates the url for the runner directory of `AarKay`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func runnerPath(global: Bool = false) -> URL {
        return aarkayPath(global: global).appendingPathComponent("AarKayRunner", isDirectory: true)
    }

    /// Creates the url for the build path of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func buildPath(global: Bool = false) -> URL {
        return runnerPath(global: global).appendingPathComponent(".build", isDirectory: true)
    }

    /// Creates the url for the `AarKayRunner` executable.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func cliPath(global: Bool = false) -> URL {
        return buildPath(global: global).appendingPathComponent("debug/aarkay-cli")
    }

    /// Creates the url for the `main.swift` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func mainSwift(global: Bool = false) -> URL {
        return runnerPath(global: global).appendingPathComponent("Sources/AarKayCLI/main.swift")
    }

    /// Creates the url of `Package.swift` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func packageSwift(global: Bool = false) -> URL {
        return runnerPath(global: global).appendingPathComponent("Package.swift")
    }

    /// Creates the url of `Package.resolved` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func packageResolved(global: Bool = false) -> URL {
        return runnerPath(global: global).appendingPathComponent("Package.resolved")
    }

    /// Creates the url of `.swift-version` file of `AarKayRunner`.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func swiftVersion(global: Bool = false) -> URL {
        return runnerPath(global: global).appendingPathComponent(".swift-version")
    }

    /// Creates the url of `AarKayFile` file of `AarKayRunner`. This file is used to add user plugins.
    ///
    /// - Parameter global: Decides whether to construct url relative to global directory or local directory.
    /// - Returns: The created url.
    public func aarkayFile(global: Bool = false) -> URL {
        return aarkayPath(global: global).appendingPathComponent("AarKayFile")
    }
}
