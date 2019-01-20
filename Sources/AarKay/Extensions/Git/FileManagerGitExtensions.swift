//
//  FileManagerGitExtensions.swift
//  AarKay
//
//  Created by RahulKatariya on 01/01/19.
//

import AarKayKit
import Foundation

extension FileManager: GitExtensionsProvider {}

extension Git where Base == FileManager {
    /// Checks whether the directory has files present inside and if there are files, then it checks whether it is a clean git repository without uncomitted changes.
    ///
    /// - Parameter url: The url of directory.
    /// - Returns: False if the directory is dirty otherwise true.
    /// - Throws: An error if url contents return nil.
    func isDirty(url: URL) throws -> Bool {
        let contents = try Try {
            try self.base.contentsOfDirectory(atPath: url.path)
                .filter { $0 != ".DS_Strore" }
        }.catchMapError { error in
            AarKayError.internalError(
                "Failed to fetch contents of directory at \(url.absoluteString)",
                with: error
            )
        }

        // Return false if the directory is empty
        guard contents.count != 0 else { return false }

        // Whether the url is a git directory
        let status = BashProcess.run(
            command: "[ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1",
            url: url
        )
        // Return false if the directory is not a git repository
        guard status == 0 else { return true }

        return BashProcess.run(
            command: "[[ -z $(git status --porcelain) ]]",
            url: url
        ) == 0 ? false : true
    }
}
