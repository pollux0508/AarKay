//
//  AarKayGlobal.swift
//  AarKay
//
//  Created by RahulKatariya on 21/01/19.
//

import AarKayKit
import AarKayRunnerKit
import Foundation
import Yams

/// A type encapsulating the global properties of AarKay.
struct AarKayGlobal {
    /// The project url.
    let url: URL

    /// Creates the global templates directory path.
    ///
    /// - Parameter aarkayPaths: The `AarKayPaths`.
    /// - Returns: Returns the url of templates directory.
    func templatesUrl(aarkayPaths: AarKayPaths) -> URL? {
        guard url != aarkayPaths.directoryPath(global: true) else {
            return nil
        }
        let aarkayTemplatesUrl = aarkayPaths
            .aarkayPath(global: true)
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
        guard FileManager.default.fileExists(atPath: aarkayGlobalContextUrl.path) else {
            return nil
        }
        let contents = try Try {
            try String(contentsOf: aarkayGlobalContextUrl)
        }.catchMapError { error in
            AarKayError.internalError(
                "Failed to read the contents of \(aarkayGlobalContextUrl)",
                with: error
            )
        }
        let object = try Yams.load(yaml: contents)
        guard let obj = object as? [String: Any] else {
            throw AarKayError.globalContextReadFailed(url: aarkayGlobalContextUrl)
        }
        return obj
    }
}
