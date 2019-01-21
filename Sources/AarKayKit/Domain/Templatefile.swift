//
//  Templatefile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 21/01/19.
//

import Foundation

struct Templatefile {
    let name: String
    let template: String
    let ext: String?
    let type: String
    
    init(template: String) throws {
        let fc = template.components(separatedBy: ".")
        guard fc.count > 1 && fc.count <= 3 else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .invalidName(name: template)
            )
        }
        self.template = template
        self.name = fc[0]
        self.ext = fc.count == 3 ? fc[1] : nil
        self.type = fc.count == 3 ? fc[2] : fc[1]
    }
}

public class Templatefiles {
    let plugin: String
    var directories: [URL]!
    let fileManager: FileManager
    private var files: [String: [Templatefile]]!

    public init(
        plugin: String,
        templatesDir: [URL],
        fileManager: FileManager
    ) throws {
        self.plugin = plugin
        self.fileManager = fileManager
        let templatesRootDirs = try templatesDirectories(urls: templatesDir)
        self.directories = try fileManager.subDirectories(at: templatesRootDirs)
        self.files = try templates(urls: templatesRootDirs)
        guard files.count > 0 else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .templatesNil(name: plugin)
            )
        }
    }

    func getTemplatefile(for template: String) throws -> [Templatefile] {
        guard let templatefiles = files[template] else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .notFound(name: template)
            )
        }
        guard templatefiles.count == 1 else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .mutipleFound(name: template)
            )
        }
        return templatefiles
    }
}

// MARK: - Private Helpers

extension Templatefiles {
    private func templatesDirectories(urls: [URL]) throws -> [URL] {
        return try urls.map { templateUrl in
            guard templateUrl.lastPathComponent != "AarKayTemplates" else {
                return templateUrl
            }
            var url = templateUrl
            while url.lastPathComponent != "Sources" {
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
    
    fileprivate func templates(urls: [URL]) throws -> [String: [Templatefile]] {
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
