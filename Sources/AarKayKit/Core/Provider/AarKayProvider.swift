//
//  AarKayProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/10/18.
//

import Foundation
import Result

struct AarKayProvider: AarKayService {
    func templateClass(
        plugin: String,
        template: String
    ) -> Templatable.Type? {
        if let templateClass = NSClassFromString("\(plugin).\(template)") as? Templatable.Type {
            return templateClass
        } else if let templateClass = NSClassFromString("aarkay_plugin_\(plugin.lowercased()).\(template)") as? Templatable.Type {
            return templateClass
        } else {
            return nil
        }
    }

    func serialize(
        plugin: String,
        name: String,
        template: String,
        contents: String,
        globalContext: [String: Any]?,
        using serializer: InputSerializable
    ) throws -> [Result<Datafile, AnyError>] {
        let context = try serializer.context(contents: contents)
        if name.rk.isCollection {
            let contextArray = context as? [[String: Any]] ?? [[:]]
            return datafiles(
                plugin: plugin,
                contextArray: contextArray,
                template: template,
                globalContext: globalContext
            )
        } else {
            let context = context as? [String: Any] ?? [:]
            let df = datafile(
                fileName: name,
                context: context,
                template: template,
                globalContext: globalContext
            )
            return [Result<Datafile, AnyError>.success(df)]
        }
    }

    func templateDatafiles(
        datafile: Datafile,
        templateClass: Templatable.Type
    ) -> [Result<Datafile, AnyError>] {
        let result = Result<[Datafile], AnyError> {
            let templatable = try templateClass.init(
                datafile: datafile
            )
            let datafiles = try templatable.datafiles()
            return datafiles
        }
        switch result {
        case .success(let files):
            return files.map { Result<Datafile, AnyError>.success($0) }
        case .failure(let error):
            return [Result<Datafile, AnyError>.failure(error)]
        }
    }

    func generatedFiles(
        urls: [URL],
        datafiles: [Result<Datafile, AnyError>],
        globalContext: [String: Any]?
    ) -> [Result<GeneratedFile, AnyError>] {
        return datafiles.map { result -> Result<[GeneratedFile], AnyError> in
            switch result {
            case .success(let value):
                return Result {
                    let files = try generatedFiles(
                        urls: urls, datafile: value, globalContext: globalContext
                    )
                    guard files.count == 1 else {
                        throw AnyError(
                            AarKayError.multipleTemplatesFound(value.template.name())
                        )
                    }
                    return files
                }
            case .failure(let error):
                return .failure(error)
            }
        }.reduce(
            [Result<GeneratedFile, AnyError>]()
        ) { (initial, next) -> [Result<GeneratedFile, AnyError>] in
            var results = initial
            switch next {
            case .failure(let error):
                results.append(.failure(error))
            case .success(let files):
                results = results + files.map { .success($0) }
            }
            return results
        }
    }
}

// MARK: - Private Helpers

extension AarKayProvider {
    private func datafile(
        fileName: String,
        context: [String: Any],
        template: String,
        globalContext: [String: Any]?
    ) -> Datafile {
        let fileName = context.rk.fileName() ?? fileName
        return Datafile(
            fileName: fileName.rk.standardized,
            directory: context.rk.dirName(),
            context: context,
            override: context.rk.override(),
            template: .name(template),
            globalContext: globalContext
        )
    }

    private func datafiles(
        plugin: String,
        contextArray: [[String: Any]],
        template: String,
        globalContext: [String: Any]?
    ) -> [Result<Datafile, AnyError>] {
        return contextArray.map { context -> Result<Datafile, AnyError> in
            Result<Datafile, AnyError> {
                guard let fileName = context.rk.fileName() ?? context["name"] as? String else {
                    throw AarKayError.missingFileName(plugin, template)
                }
                return datafile(
                    fileName: fileName,
                    context: context,
                    template: template,
                    globalContext: globalContext
                )
            }
        }
    }

    private func generatedFiles(
        urls: [URL],
        datafile: Datafile,
        globalContext: [String: Any]?
    ) throws -> [GeneratedFile] {
        switch datafile.template {
        case .name(let name):
            let templates = try AarKayTemplates.default.renderTemplate(
                urls: urls,
                name: name,
                context: datafile.globalContext + datafile.context
            )
            return templates.map {
                generatedFile(
                    datafile: datafile,
                    stringContents: $0.0,
                    pathExtension: $0.1
                )
            }
        case .nameStringExt(_, let string, let ext):
            let file = generatedFile(
                datafile: datafile,
                stringContents: string,
                pathExtension: ext
            )
            return [file]
        }
    }

    private func generatedFile(
        datafile: Datafile,
        stringContents: String,
        pathExtension: String?
    ) -> GeneratedFile {
        let file = GeneratedFile(
            name: datafile.fileName,
            ext: pathExtension,
            directory: datafile.directory,
            override: datafile.override,
            contents: stringContents
        )
        return file
    }

}
