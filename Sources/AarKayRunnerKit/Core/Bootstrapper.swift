//
//  Bootstrapper.swift
//  AarKayRunner
//
//  Created by Rahul Katariya on 04/03/18.
//

import Foundation
import SharedKit

/// Responsible for creating files required by `AarKayRunner`.
public struct Bootstrapper {
    /// The AarKayPaths
    public let aarkayPaths: AarKayPaths

    /// The `FileManager`
    public let fileManager: FileManager

    /// Initializes the Bootstrapper.
    ///
    /// - Parameters:
    ///   - aarkayPaths: The AarKayPaths.
    ///   - fileManager: The FileManager.
    public init(
        aarkayPaths: AarKayPaths,
        fileManager: FileManager
    ) {
        self.aarkayPaths = aarkayPaths
        self.fileManager = fileManager
    }

    /// Initializes the local Bootstrapper with aarkayPaths local and fileManager.
    public static let local = Bootstrapper(
        aarkayPaths: AarKayPaths.local,
        fileManager: FileManager.default
    )

    /// Initializes the global Bootstrapper with aarkayPaths global and fileManager.
    public static let global = Bootstrapper(
        aarkayPaths: AarKayPaths.global,
        fileManager: FileManager.default
    )

    /// Creates all files required to run `AarKay`.
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    ///   - force: Setting force to true will delete all the files before creating them.
    /// - Throws: File manager errors
    public func bootstrap(force: Bool = false) throws {
        if force {
            let buildUrl = aarkayPaths.buildPath()
            if fileManager.fileExists(atPath: buildUrl.path) {
                try Try {
                    try self.fileManager.removeItem(at: buildUrl)
                }.do { error in
                    AarKayError.internalError(
                        "Failed to remove build at \(buildUrl)", with: error
                    )
                }
            }
        }
        try createCLISwift(force: force)
        try createAarKayFile()
        try updatePackageSwift(force: force)
        try createSwiftVersion(force: force)
    }

    /// Creates CLI main.swift file
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    ///   - force: Setting force to true will delete all the files before creating them.
    /// - Throws: File manager errors
    private func createCLISwift(
        force: Bool = false
    ) throws {
        let url = aarkayPaths.mainSwift()
        try write(string: RunnerFiles.cliSwift, url: url, force: force)
    }

    /// Creates .swift-version file.
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    ///   - force: Setting force to true will delete all the files before creating them.
    /// - Throws: File manager errors
    private func createSwiftVersion(
        force: Bool = false
    ) throws {
        let url = aarkayPaths.swiftVersion()
        try write(string: RunnerFiles.swiftVersion, url: url, force: force)
    }

    /// Creates `AarKayFile` if it doesn't exist already.
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    /// - Throws: File manager errors
    private func createAarKayFile() throws {
        let url = aarkayPaths.aarkayFile()
        if !fileManager.fileExists(atPath: url.path) {
            try write(string: RunnerFiles.aarkayFile, url: url, force: false)
        }
    }

    /// Updates `Package.swift` with `AarKayFile` dependencies.
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    ///   - force: Setting force to true will delete the `packaged.resolved` before creating it.
    /// - Throws: File manager errors
    public func updatePackageSwift(
        force: Bool = false
    ) throws {
        if force {
            let packageResolvedUrl = aarkayPaths.packageResolved()
            if fileManager.fileExists(atPath: packageResolvedUrl.path) {
                try Try {
                    try self.fileManager.removeItem(at: packageResolvedUrl)
                }.do { error in
                    AarKayError.internalError(
                        "Failed to remove Package.resolved at \(packageResolvedUrl)", with: error
                    )
                }
            }
        }
        let aarkayFileUrl = aarkayPaths.aarkayFile()
        let deps: [Dependency] = try AarKayFile(
            url: aarkayFileUrl,
            fileManager: fileManager
        ).dependencies
        let contents = RunnerFiles.packageSwift(deps: deps)
        let url = aarkayPaths.packageSwift()
        try write(string: contents, url: url, force: true)
    }

    /// Writes the string to the destination url atomically and using .utf8 encoding.
    ///
    /// - Parameters:
    ///   - string: The string to write to the file.
    ///   - url: The destination of the file.
    ///   - force: Setting force to true will delete all the files before creating them.
    /// - Throws: File manager errors
    private func write(string: String, url: URL, force: Bool) throws {
        if force {
            if fileManager.fileExists(atPath: url.path) {
                try Try {
                    try self.fileManager.removeItem(at: url)
                }.do { error in
                    AarKayError.internalError(
                        "Failed to remove file at \(url)", with: error
                    )
                }
            }
        }

        try Try {
            try self.fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
            try string.write(to: url, atomically: true, encoding: .utf8)
        }.do { error in
            AarKayError.internalError(
                "Failed to write \(string) at \(url)", with: error
            )
        }
    }
}
