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
        guard files.count > 0 else { return nil }
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
            guard templateUrl.lastPathComponent != "AarKayTemplates" else {
                return templateUrl
            }
            var url = templateUrl
            while url.lastPathComponent != "Sources" &&
                url.lastPathComponent != "Tests" {
                if url.lastPathComponent == "/" {
                    throw AarKayKitError.internalError(
                        "Incorrect plugin structure at \(templateUrl.path)"
                    )
                }
                url = url.deletingLastPathComponent()
            }
            url = url
                .deletingLastPathComponent()
                .appendingPathComponent(
                    "AarKay/AarKayTemplates",
                    isDirectory: true
                )
            guard fileManager.fileExists(atPath: url.path) else {
                throw AarKayKitError.internalError(
                    "Incorrect plugin structure at \(templateUrl)"
                )
            }
            if url.path.hasPrefix("/tmp") {
                print("[OLD]", url.absoluteString)
                let pathComponents = Array(url.pathComponents.dropFirst().dropFirst())
                let newPath = "/" + pathComponents.joined(separator: "/")
                url = URL(fileURLWithPath: newPath, isDirectory: true)
                print("[NEW]", url.absoluteString)
            }
            return url
        }
    }

    fileprivate func templatesFiles(urls: [URL]) throws -> [String: [Templatefile]] {
        let templatesfiles = try fileManager.subFiles(at: urls)
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .map { try Templatefile(template: $0.lastPathComponent) }
        let templates = templatesfiles
            .reduce(Dictionary<String, [Templatefile]>()) { initial, item in
                var initial = initial
                initial[item.name] = (initial[item.name] ?? []) + [item]
                return initial
            }
        return templates
    }
}
