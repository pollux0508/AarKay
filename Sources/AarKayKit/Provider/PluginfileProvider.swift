//
//  PluginfileProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/01/19.
//

import Foundation

struct PluginfileProvider: PluginfileService {
    let pluginfile: Pluginfile

    func templateProvider(fileManager: FileManager) throws -> TemplateService {
        if let templateService = try templateService(
            plugin: pluginfile.name,
            fileManager: fileManager
        ) {
            return templateService
        } else {
            guard let globalTemplates = pluginfile.globalTemplates else {
                throw AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .templatesNil(name: pluginfile.name)
                )
            }
            guard let templates = try Templates(
                fileManager: fileManager,
                templates: globalTemplates
            ) else {
                throw AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .templatesNil(name: pluginfile.name)
                )
            }
            return StencilProvider(templates: templates)
        }
    }
}

// MARK: - Private Helpers

extension PluginfileProvider {
    private func templateService(
        plugin: String,
        fileManager: FileManager
    ) throws -> TemplateService? {
        guard let plugable = plugableClass(plugin: plugin) else {
            return nil
        }

        guard let templates = try Templates(
            fileManager: fileManager,
            templates: plugable.templates().map { URL(fileURLWithPath: $0) }
        ) else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .templatesNil(name: pluginfile.name)
            )
        }

        return try plugable.templateService().init(
            templates: templates
        )
    }

    private func plugableClass(
        plugin: String
    ) -> Plugable.Type? {
        if let plugable = NSClassFromString("\(plugin).\(plugin)") as? Plugable.Type {
            return plugable
        } else if let plugable = NSClassFromString("aarkay_plugin_\(plugin.lowercased()).\(plugin)") as? Plugable.Type {
            return plugable
        } else {
            return nil
        }
    }
}
