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
    let aarkayPaths: AarKayPaths

    /// The `FileManager`
    let fileManager: FileManager

    /// Initializes the default Bootstrapper with aarkayPaths and fileManager.
    public static let `default` = Bootstrapper(
        aarkayPaths: AarKayPaths.default,
        fileManager: FileManager.default
    )

    /// Creates all files required to run `AarKay`.
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    ///   - force: Setting force to true will delete all the files before creating them.
    /// - Throws: File manager errors
    public func bootstrap(global: Bool = false, force: Bool = false) throws {
        if force {
            let buildUrl = aarkayPaths.buildPath(global: global)
            if fileManager.fileExists(atPath: buildUrl.path) {
                try Try {
                    try self.fileManager.removeItem(at: buildUrl)
                }.catch { error in
                    AarKayError.internalError(
                        "Failed to remove build at \(buildUrl)", with: error
                    )
                }
            }
        }
        try createCLISwift(global: global, force: force)
        try createAarKayFile(global: global)
        try updatePackageSwift(global: global, force: force)
        try createSwiftVersion(global: global, force: force)
    }

    /// Creates CLI main.swift file
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    ///   - force: Setting force to true will delete all the files before creating them.
    /// - Throws: File manager errors
    private func createCLISwift(global: Bool, force: Bool = false) throws {
        let url = aarkayPaths.mainSwift(global: global)
        try write(string: RunnerFiles.cliSwift, url: url, force: force)
    }

    /// Creates .swift-version file.
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    ///   - force: Setting force to true will delete all the files before creating them.
    /// - Throws: File manager errors
    private func createSwiftVersion(global: Bool, force: Bool = false) throws {
        let url = aarkayPaths.swiftVersion(global: global)
        try write(string: RunnerFiles.swiftVersion, url: url, force: force)
    }

    /// Creates `AarKayFile` if it doesn't exist already.
    ///
    /// - Parameters:
    ///   - global: Setting global to true will bootstrap the `AarKay` project inside home directory otherwise will setup in the local directory.
    /// - Throws: File manager errors
    private func createAarKayFile(global: Bool) throws {
        let url = aarkayPaths.aarkayFile(global: global)
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
    public func updatePackageSwift(global: Bool, force: Bool = false) throws {
        if force {
            let packageResolvedUrl = aarkayPaths.packageResolved(global: global)
            if fileManager.fileExists(atPath: packageResolvedUrl.path) {
                try Try {
                    try self.fileManager.removeItem(at: packageResolvedUrl)
                }.catch { error in
                    AarKayError.internalError(
                        "Failed to remove Package.resolved at \(packageResolvedUrl)", with: error
                    )
                }
            }
        }
        let aarkayFileUrl = aarkayPaths.aarkayFile(global: global)
        let deps: [Dependency] = try AarKayFile(
            url: aarkayFileUrl,
            fileManager: fileManager
        ).dependencies
        let contents = RunnerFiles.packageSwift(deps: deps)
        let url = aarkayPaths.packageSwift(global: global)
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
                }.catch { error in
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
        }.catch { error in
            AarKayError.internalError(
                "Failed to write \(string) at \(url)", with: error
            )
        }
    }
}
