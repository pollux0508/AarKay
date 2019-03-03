//
//  AarKayGlobal.swift
//  AarKay
//
//  Created by RahulKatariya on 21/01/19.
//

import AarKayRunnerKit
import Foundation
import Yams

/// A type encapsulating the global properties of AarKay.
struct AarKayGlobal {
    /// The location of AarKay project.
    let url: URL

    /// The FileManager.
    let fileManager: FileManager

    /// Creates the global templates directory path.
    ///
    /// - Parameter aarkayPaths: The `AarKayPaths`.
    /// - Returns: Returns the url of templates directory.
    func templatesUrl(aarkayPaths: AarKayPaths) -> URL? {
        guard url != aarkayPaths.url else {
            return nil
        }
        let aarkayTemplatesUrl = aarkayPaths
            .aarkayPath()
            .appendingPathComponent(
                "AarKayTemplates",
                isDirectory: true
            )
        return aarkayTemplatesUrl
    }

    /// Reads the global context url from the path "{PROJECT_ROOT}/AarKay/.aarkay" and serializes it into a dictionary using Yaml serialzer.
    ///
    /// - Returns: The dictionary from contents.
    /// - Throws: An error if the url contents cannot be loaded.
    func context() throws -> [String: Any]? {
        let aarkayGlobalContextUrl = url.appendingPathComponent("AarKay/.aarkay")
        guard fileManager.fileExists(atPath: aarkayGlobalContextUrl.path) else {
            return nil
        }
        var contents: String!
        do {
            contents = try String(contentsOf: aarkayGlobalContextUrl)
        } catch {
            throw AarKayError.internalError(
                "Failed to read the contents of \(aarkayGlobalContextUrl)",
                with: error
            )
        }
        let object = try Yams.load(yaml: contents)
        guard let obj = object else {
            return [:]
        }
        guard let dict = obj as? [String: Any] else {
            throw AarKayError.globalContextReadFailed(url: aarkayGlobalContextUrl)
        }
        return dict
    }
}
