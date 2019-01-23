//
//  AarKayKit.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 04/12/17.
//

import Foundation
import Result

public struct AarKayKit {
    let pluginfile: Pluginfile
    let fileManager: FileManager
    var aarkayService: AarKayService!

    public init(
        plugin: String,
        globalContext: [String: Any]?,
        globalTemplates: [URL]?,
        fileManager: FileManager = FileManager.default
    ) throws {
        self.fileManager = fileManager
        self.pluginfile = Pluginfile(
            name: plugin,
            globalContext: globalContext,
            globalTemplates: globalTemplates
        )
        let pluginfileService = PluginfileProvider(pluginfile: pluginfile)
        self.aarkayService = AarKayProvider(
            pluginfileService: pluginfileService,
            datafileService: DatafileProvider(),
            generatedfileService: GeneratedfileProvider(
                templatesService: try pluginfileService.templateProvider(
                    fileManager: fileManager
                )
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
        if let templateClass = aarkayService.datafileService.templateClass(
            plugin: pluginfile.name,
            template: template
        ) {
            let datafiles = try aarkayService.datafileService.serialize(
                plugin: pluginfile.name,
                name: name,
                template: template,
                contents: contents,
                globalContext: pluginfile.globalContext,
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
                globalContext: pluginfile.globalContext
            )
        } else {
            let datafiles = try aarkayService.datafileService.serialize(
                plugin: pluginfile.name,
                name: name,
                template: template,
                contents: contents,
                globalContext: pluginfile.globalContext,
                using: YamlInputSerializer()
            )

            return aarkayService.generatedfileService.generatedfiles(
                datafiles: datafiles,
                globalContext: pluginfile.globalContext
            )
        }
    }
}
