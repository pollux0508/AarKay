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
    let name: String
    let directory: String?
    let template: String
    let contents: String
    let globalContext: [String: Any]?
    let globalTemplates: [URL]?
    let aarkayService: AarKayService
}

extension AarKayKit {
    public static func bootstrap(
        plugin: String,
        globalContext: [String: Any]?,
        fileName: String,
        directory: String?,
        template: String,
        contents: String,
        globalTemplates: [URL]?
    ) throws -> [Result<GeneratedFile, AnyError>] {
        let aarkayKit = AarKayKit(
            plugin: plugin,
            name: fileName,
            directory: directory,
            template: template,
            contents: contents,
            globalContext: globalContext,
            globalTemplates: globalTemplates,
            aarkayService: AarKayProvider()
        )

        return try aarkayKit.bootstrap()
    }
}

extension AarKayKit {
    func bootstrap() throws -> [Result<GeneratedFile, AnyError>] {
        if let templateClass = aarkayService.templateClass(
            plugin: plugin,
            template: template
        ) {
            return try bootstrap(templateClass: templateClass)
        } else {
            guard let globalTempaltes = globalTemplates else {
                throw AarKayError.templateNotFound(template)
            }

            let datafiles = try aarkayService.serialize(
                plugin: plugin,
                name: name,
                template: template,
                contents: contents,
                globalContext: globalContext,
                using: YamlInputSerializer()
            )

            return aarkayService.generatedFiles(
                urls: globalTempaltes,
                datafiles: datafiles,
                globalContext: globalContext
            )
        }
    }

    func bootstrap(templateClass: Templatable.Type) throws -> [Result<GeneratedFile, AnyError>] {
        let datafiles = try aarkayService.serialize(
            plugin: plugin,
            name: name,
            template: template,
            contents: contents,
            globalContext: globalContext,
            using: templateClass.inputSerializer()
        )

        let generatedFiles = datafiles
            .map { result -> [Result<Datafile, AnyError>] in
                switch result {
                case .success(let value):
                    let datafiles = aarkayService.templateDatafiles(
                        datafile: value,
                        templateClass: templateClass
                    )
                    return datafiles
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

        let templateUrls = templateClass.templates()
            .map { URL(fileURLWithPath: $0) }
            .rk.templatesDirectory()
        return aarkayService.generatedFiles(
            urls: templateUrls,
            datafiles: generatedFiles,
            globalContext: globalContext
        )
    }
}
