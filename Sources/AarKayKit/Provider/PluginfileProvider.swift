//
//  PluginfileProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/01/19.
//

import Foundation

struct PluginfileProvider: PluginfileService {
    let pluginfile: Pluginfile
    
    func templatefiles(fileManager: FileManager) throws -> TemplateService {
        if let templateService = try templateService(
            plugin: pluginfile.name,
            fileManager: fileManager
        ) {
            return templateService
        } else {
            guard let templates = pluginfile.globalTemplates else {
                throw AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .templatesNil(name: pluginfile.name)
                )
            }
            let templatefiles = try Templatefiles(
                plugin: pluginfile.name,
                templatesDir: templates,
                fileManager: fileManager
            )
            return StencilProvider(templatefiles: templatefiles)
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
        let templatefiles = try Templatefiles(
            plugin: plugin,
            templatesDir: plugable.templates().map { URL(fileURLWithPath: $0) },
            fileManager: fileManager
        )
        return try plugable.templateService().init(
            templatefiles: templatefiles
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
