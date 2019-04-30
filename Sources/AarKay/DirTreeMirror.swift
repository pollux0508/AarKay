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
        guard let subpaths = fileManager.enumerator(
            at: sourceUrl,
            includingPropertiesForKeys: nil,
            options: [.skipsPackageDescendants, .skipsHiddenFiles],
            errorHandler: nil
        ) else {
            fatalError()
        }
        let mirrorUrls: [(URL, URL)] = subpaths.map { $0 as! URL }
            .filter { $0.shouldAllow() }
            .map { $0.setBaseURL(sourceUrl) }
            .map {
                (
                    $0, URL(
                        fileURLWithPath: $0.relativePath,
                        relativeTo: destinationUrl
                    )
                )
            }
        return mirrorUrls
    }
}

extension URL {
    fileprivate func shouldAllow() -> Bool {
        return (try! resourceValues(forKeys: [.isRegularFileKey]).isRegularFile!)
            || (try! resourceValues(forKeys: [.isPackageKey]).isPackage!)
            || (try! resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink!)
    }

    fileprivate func setBaseURL(_ url: URL) -> URL {
        let basePath = try! url.resourceValues(forKeys: [.canonicalPathKey]).canonicalPath
        let cannoicalPath = try! resourceValues(forKeys: [.canonicalPathKey]).canonicalPath
        let path = cannoicalPath!.replacingOccurrences(of: basePath! + "/", with: "")
        let finalUrl = URL(fileURLWithPath: path, isDirectory: false, relativeTo: url)
        return finalUrl
    }
}
