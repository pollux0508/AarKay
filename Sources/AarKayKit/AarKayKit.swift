//
//  AarKayKit.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 04/12/17.
//

import Foundation
import Result

public struct AarKayKit {
    let plugin: String
    let globalContext: [String: Any]?
    let globalTemplates: [URL]?
    let fileManager: FileManager
    var aarkayService: AarKayService!

    public init(
        plugin: String,
        globalContext: [String: Any]?,
        globalTemplates: [URL]?,
        fileManager: FileManager = FileManager.default
    ) throws {
        self.plugin = plugin
        self.globalContext = globalContext
        self.globalTemplates = globalTemplates
        self.fileManager = fileManager
        self.aarkayService = AarKayProvider(
            datafileService: DatafileProvider(),
            generatedfileService: GeneratedfileProvider(
                templatesService: try templatefiles(plugin: plugin)
            )
        )
    }
}

extension AarKayKit {
    public func bootstrap(
        name: String,
        directory: String?,
        template: String,
        contents: String
    ) throws -> [Result<Generatedfile, AnyError>] {
        if let templateClass = aarkayService.templateClass(
            plugin: plugin,
            template: template
        ) {
            return try bootstrap(
                templateClass: templateClass,
                name: name,
                directory: directory,
                template: template,
                contents: contents
            )
        } else {
            let datafiles = try aarkayService.datafileService.serialize(
                plugin: plugin,
                name: name,
                template: template,
                contents: contents,
                globalContext: globalContext,
                using: YamlInputSerializer()
            )

            return aarkayService.generatedfileService.generatedfiles(
                datafiles: datafiles,
                globalContext: globalContext
            )
        }
    }

    func bootstrap(
        templateClass: Templatable.Type,
        name: String,
        directory: String?,
        template: String,
        contents: String
    ) throws -> [Result<Generatedfile, AnyError>] {
        let datafiles = try aarkayService.datafileService.serialize(
            plugin: plugin,
            name: name,
            template: template,
            contents: contents,
            globalContext: globalContext,
            using: templateClass.inputSerializer()
        )

        let templateDatafiles = datafiles
            .map { result -> [Result<Datafile, AnyError>] in
                switch result {
                case .success(let value):
                    let res = Result {
                        return try aarkayService.datafileService
                            .templateDatafiles(
                                datafile: value,
                                templateClass: templateClass
                            )
                    }
                    switch res {
                    case .success(let files):
                        return files.map { .success($0) }
                    case .failure(let error):
                        return [.failure(error)]
                    }
                case .failure(let error):
                    return [.failure(error)]
                }
            }.reduce(
                [Result<Datafile, AnyError>]()
            ) { (initial, next) -> [Result<Datafile, AnyError>] in
                var results: [Result<Datafile, AnyError>] = initial
                next.forEach { results.append($0) }
                return results
            }

        return aarkayService.generatedfileService.generatedfiles(
            datafiles: templateDatafiles,
            globalContext: globalContext
        )
    }
}

// MARK: - Private Helpers

extension AarKayKit {
    private func templatefiles(plugin: String) throws -> TemplateService {
        var templateServiceClass: TemplateService.Type = StencilProvider.self
        var templatefiles: Templatefiles!
        if let plugable = NSClassFromString("\(plugin).\(plugin)") as? Plugable.Type {
            templatefiles = try Templatefiles(
                plugin: plugin,
                templatesDir: plugable.templates().map { URL(fileURLWithPath: $0) },
                fileManager: fileManager
            )
            templateServiceClass = plugable.templateService()
        } else if let plugable = NSClassFromString("aarkay_plugin_\(plugin.lowercased()).\(plugin)") as? Plugable.Type {
            templatefiles = try Templatefiles(
                plugin: plugin,
                templatesDir: plugable.templates().map { URL(fileURLWithPath: $0) },
                fileManager: fileManager
            )
            templateServiceClass = plugable.templateService()
        } else {
            guard let templates = globalTemplates else {
                throw AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .templatesNil(name: plugin)
                )
            }
            templatefiles = try Templatefiles(
                plugin: plugin,
                templatesDir: templates,
                fileManager: fileManager
            )
        }
        return try templateServiceClass.init(
            templatefiles: templatefiles
        )
    }
}
