//
//  AarKayProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/10/18.
//

import Foundation
import Result

struct AarKayProvider: AarKayService {
    var datafileService: DatafileService
    var generatedfileService: GeneratedfileService

    func plugableClass(
        plugin: String
    ) throws -> Plugable.Type? {
        guard plugin.lowercased() != "noplugin" else { return nil }
        if let plugableClass = NSClassFromString(
            "\(plugin).AarKayPlugin"
        ) as? Plugable.Type {
            return plugableClass
        } else if let plugableClass = NSClassFromString(
            "aarkay_plugin_\(plugin.lowercased()).AarKayPlugin"
        ) as? Plugable.Type {
            return plugableClass
        } else {
            throw AarKayKitError.invalidPlugin(name: plugin)
        }
    }

    func templateProvider(
        plugin: String,
        globalTemplates: [URL]?,
        fileManager: FileManager
    ) throws -> TemplateService {
        if let templateService = try templateService(
            plugin: plugin,
            fileManager: fileManager
        ) {
            return templateService
        } else {
            guard let globalTemplates = globalTemplates else {
                throw AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .templatesNil(name: plugin)
                )
            }
            let templates = try Templates(
                fileManager: fileManager,
                templates: globalTemplates
            )
            return StencilProvider(templates: templates)
        }
    }
}

// MARK: - Private Helpers

extension AarKayProvider {
    private func templateService(
        plugin: String,
        fileManager: FileManager
    ) throws -> TemplateService? {
        guard let plugable = try plugableClass(plugin: plugin) else {
            return nil
        }

        let templates = try Templates(
            fileManager: fileManager,
            templates: plugable.templates().map { templateUrl in
                var url = URL(fileURLWithPath: templateUrl)
                if url.path.hasPrefix("/tmp") {
                    print("[OLD]", url.absoluteString)
                    let pathComponents = Array(url.pathComponents.dropFirst().dropFirst())
                    let newPath = "/" + pathComponents.joined(separator: "/")
                    url = URL(fileURLWithPath: newPath, isDirectory: true)
                    print("[NEW]", url.absoluteString)
                }
                while url.lastPathComponent != "Sources" &&
                    url.lastPathComponent != "Tests" {
                    if url.lastPathComponent == "/" {
                        throw AarKayKitError.internalError(
                            "Incorrect plugin structure at \(templateUrl)"
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
                return url
            }
        )

        return try plugable.templateService().init(
            templates: templates
        )
    }
}
