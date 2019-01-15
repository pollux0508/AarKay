//
//  DirTreeMirror.swift
//  AarKay
//
//  Created by Rahul Katariya on 13/10/17.
//  Copyright © 2017 RahulKatariya. All rights reserved.
//

import Foundation

/// Represents a recursive directory tree soft mirror with respect to the source directory.
///
///     +-----------------------+                   +-----------------------+
///     | - DirOnDisk/*         |                   | - MirrorDir/*         |
///     |-----------------------|                   |-----------------------|
///     |   - SubDir1/          |                   |   - SubDir1/          |
///     |     - SubSubDir1/     |                   |     - SubSubDir1/     |
///     |       - File1.swift   |                   |       - File1.swift   |
///     |       - File2.swift   |                   |       - File2.swift   |
///     |       - File3.txt     | ================> |       - File3.txt     |
///     |     - SubSubDir2/     |                   |     - SubSubDir2/     |
///     |       - File.txt      |                   |       - File.txt      |
///     |   - SubDir2/          |                   |   - SubDir2/          |
///     |     - SubDir/         |                   |     - SubDir/         |
///     |       - File.txt      |                   |       - File.txt      |
///     +-----------------------+                   +-----------------------+
///
/// - note: It only mirrors an existing directory tree with another directory and doesn't create the actual files in the mirrored directory.
class DirTreeMirror {
    /// The source url.
    let sourceUrl: URL

    /// The destination url.
    let destinationUrl: URL

    /// The file manager.
    let fileManager: FileManager

    /// Initializes the `DirTreeMirror` with source and destination directories.
    ///
    /// - Parameters:
    ///   - sourceUrl: The url of source directory.
    ///   - destinationUrl: The url of destination directory.
    ///   - fileManager: The file manager.
    init(
        sourceUrl: URL,
        destinationUrl: URL,
        fileManager: FileManager = FileManager.default
    ) {
        self.sourceUrl = sourceUrl
        self.destinationUrl = destinationUrl
        self.fileManager = fileManager
    }

    /// Soft mirrors the destination directory with respect to the source directory.
    ///
    /// - Parameter filter: A filter to be applied on source url subpaths.
    /// - Returns: An array of tuple with source url and destination url.
    /// - Throws: FileManager related errors.
    func bootstrap() throws -> [(URL, URL)] {
        let subpaths = try fileManager.subpathsOfDirectory(atPath: sourceUrl.path)
        let mirrorUrls: [(URL, URL)] = subpaths
            .map {
                return URL(
                    fileURLWithPath: $0,
                    isDirectory: sourceUrl.appendingPathComponent($0).hasDirectoryPath,
                    relativeTo: sourceUrl
                )
            }
            .filter { return !$0.lastPathComponent.hasPrefix(".") && !$0.hasDirectoryPath }
            .map {
                return (
                    $0, URL(
                        fileURLWithPath: $0.relativePath,
                        isDirectory: $0.hasDirectoryPath,
                        relativeTo: destinationUrl
                    )
                )
            }
        return mirrorUrls
    }
}
