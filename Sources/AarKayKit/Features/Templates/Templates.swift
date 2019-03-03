//
//  TemplateDir.swift
//  AarKayKit
//
//  Created by RahulKatariya on 24/01/19.
//

import Foundation

/// A Type that encapsulates Templates.
public struct Templates {
    /// The FileManager.
    let fileManager: FileManager

    /// The directories.
    private(set) var directories: [URL]!

    /// The Templatefile objects.
    private(set) var files: [String: [Templatefile]]!

    /// Initializes a Templates object.
    ///
    /// - Parameters:
    ///   - fileManager: The FileManager.
    ///   - templates: The root directories of all Templates.
    /// - Throws: An `Error` if file manager operations encouter any error.
    public init?(
        fileManager: FileManager,
        templates: [URL]
    ) throws {
        self.fileManager = fileManager
        let templatesRootDirs = try templatesDirectories(urls: templates)
        self.directories = try fileManager.subDirectories(at: templatesRootDirs)
        self.files = try templatesFiles(urls: templatesRootDirs)
        guard !files.isEmpty else { return nil }
    }

    /// Finds the Templatefile stored in files corresponding the name.
    ///
    /// - Parameter template: The name of the template.
    /// - Returns: An Array of Templatefiles.
    /// - Throws: An `Error` if template file is not found or more than one exists.
    func getTemplatefile(for template: String) throws -> [Templatefile] {
        guard let templates = files[template] else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .notFound(name: template)
            )
        }
        guard templates.count == 1 else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .mutipleFound(name: template)
            )
        }
        return templates
    }
}

// MARK: - Private Helpers

extension Templates {
    private func templatesDirectories(urls: [URL]) throws -> [URL] {
        return try urls.map { templateUrl in
            guard templateUrl.lastPathComponent == "AarKayTemplates",
                fileManager.fileExists(atPath: templateUrl.path) else {
                throw AarKayKitError.internalError(
                    "Incorrect plugin structure at \(templateUrl)"
                )
            }
            return templateUrl
        }
    }

    fileprivate func templatesFiles(urls: [URL]) throws -> [String: [Templatefile]] {
        let templatesfiles = try fileManager.subFiles(at: urls)
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .map { try Templatefile(template: $0.lastPathComponent) }
        let templates = templatesfiles
            .reduce([String: [Templatefile]]()) { initial, item in
                var initial = initial
                initial[item.name] = (initial[item.name] ?? []) + [item]
                return initial
            }
        return templates
    }
}
