//
//  Plugin.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 04/12/17.
//

import Foundation

/// Represents a Plugin.
public struct Pluginfile {
    /// The name of the plugin.
    let name: String

    /// The global context shared with all Generatedfiles.
    private(set) var globalContext: [String: Any]

    /// The location of templates.
    let templates: URL?

    /// The location of global templates.
    let globalTemplates: URL?

    /// The FileManager
    let fileManager: FileManager

    /// The AarKayService
    let aarkayService: AarKayService

    /// The TemplateService
    let templateService: TemplateService

    /// Initializes a Plugin object.
    ///
    /// - Parameters:
    ///   - name: The name of the plugin.
    ///   - globalContext: The global context shared with all Generatedfiles.
    ///   - globalTemplates: The location of global templates.
    ///   - fileManager: The FileManager
    /// - Throws: An `Error` if the templates service encouters any error.
    public init(
        name: String,
        templates: URL?,
        globalTemplates: URL?,
        globalContext: [String: Any]?,
        fileManager: FileManager = FileManager.default
    ) throws {
        self.name = name
        self.templates = templates
        self.globalTemplates = globalTemplates
        self.fileManager = fileManager
        self.aarkayService = AarKayProvider(
            datafileService: DatafileProvider(),
            generatedfileService: GeneratedfileProvider()
        )
        self.templateService = try aarkayService.templateProvider(
            plugin: name,
            templates: templates,
            globalTemplates: globalTemplates,
            fileManager: fileManager
        )
        if let pluggableType = try AarKayKit.pluggableClass(plugin: name) {
            self.globalContext = try pluggableType
                .init(context: globalContext ?? [:])
                .context
        } else {
            self.globalContext = globalContext ?? [:]
        }
    }
}

extension Pluginfile {
    /// Creates GeneratedFile results from `Pluggable`.
    ///
    /// - Returns: The `Generatedfile` results.
    /// - Throws: An `Error` if the program encouters any error.
    public func bootstrap() throws -> [Result<Generatedfile, Error>] {
        if let pluggableType = try AarKayKit.pluggableClass(plugin: name) {
            let pluggable = try pluggableType.init(context: globalContext)
            let datafiles = try pluggable.datafiles().map {
                Result<Datafile, Error>.success($0)
            }
            return aarkayService.generatedfileService.generatedfiles(
                datafiles: datafiles,
                templateService: templateService
            )
        }
        return []
    }

    /// Creates GeneratedFile results from one Datafile on a disk.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - directory: The directory.
    ///   - template: The template to use.
    ///   - contents: The contents of the file.
    /// - Returns: The `Generatedfile` results.
    /// - Throws: An `Error` if the program encouters any error.
    public func generate(
        fileName: String,
        directory: String,
        template: String,
        contents: String
    ) throws -> [Result<Generatedfile, Error>] {
        if let templateClass = AarKayKit.templateClass(
            plugin: name,
            template: template
        ) {
            let datafiles = try aarkayService.datafileService.serialize(
                plugin: name,
                name: fileName,
                directory: directory,
                template: template,
                contents: contents,
                using: templateClass.inputSerializer(),
                globalContext: globalContext
            )

            let templateDatafiles = datafiles
                .map { result -> [Result<Datafile, Error>] in
                    switch result {
                    case .success(let value):
                        let res = Result<[Datafile], Error> {
                            try aarkayService.datafileService
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
                    [Result<Datafile, Error>]()
                ) { (initial, next) -> [Result<Datafile, Error>] in
                    var results: [Result<Datafile, Error>] = initial
                    next.forEach { results.append($0) }
                    return results
                }

            return aarkayService.generatedfileService.generatedfiles(
                datafiles: templateDatafiles,
                templateService: templateService
            )
        } else {
            let datafiles = try aarkayService.datafileService.serialize(
                plugin: name,
                name: fileName,
                directory: directory,
                template: template,
                contents: contents,
                using: YamlInputSerializer(),
                globalContext: globalContext
            )

            return aarkayService.generatedfileService.generatedfiles(
                datafiles: datafiles,
                templateService: templateService
            )
        }
    }
}
