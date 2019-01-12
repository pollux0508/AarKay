//
//  AarKayProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/10/18.
//

import Foundation
import Result

class AarKayProvider: AarKayService {
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

    func generatedfiles(
        datafile: Datafile,
        fileName: String?,
        contextArray: [[String: Any]],
        templateClass: Templatable.Type?
    ) -> [Result<Generatedfile, AnyError>] {
        let files = contextArray.map { context in
            Result<Generatedfile, AnyError> {
                guard let fileName: String = fileName ?? context.rk.fileName() else {
                    throw AarKayError.missingFileName(datafile.plugin, datafile.template, context)
                }
                let generatedfile = Generatedfile(
                    plugin: datafile.plugin,
                    name: fileName.rk.standardized,
                    directory: context.rk.dirName(),
                    contents: context,
                    override: context.rk.override() ?? true,
                    template: datafile.template
                )
                return generatedfile
            }
        }
        if let templateClass = templateClass {
            return self.templateGeneratedfiles(
                datafile: datafile,
                generatedfiles: files,
                templateClass: templateClass
            )
        } else {
            return files
        }
    }

    func templateGeneratedfiles(
        datafile: Datafile,
        generatedfiles: [Result<Generatedfile, AnyError>],
        templateClass: Templatable.Type
    ) -> [Result<Generatedfile, AnyError>] {
        return generatedfiles.reduce([Result<Generatedfile, AnyError>]()) { original, generatedfile in
            switch generatedfile {
            case .success(let value):
                let results = templateGeneratedfiles(
                    datafile: datafile,
                    generatedfile: value,
                    templateClass: templateClass
                )
                return original + results
            case .failure(let failure):
                return original + [.failure(failure)]
            }
        }
    }

    func templateGeneratedfiles(
        datafile: Datafile,
        generatedfile: Generatedfile,
        templateClass: Templatable.Type
    ) -> [Result<Generatedfile, AnyError>] {
        do {
            if let templatable = try templateClass.init(
                datafile: datafile,
                generatedfile: generatedfile
            ) {
                return templatable.generatedfiles().map { .success($0) }
            } else {
                let error = AarKayError.modelDecodingFailure(
                    generatedfile.name, generatedfile.template + "Model"
                )
                return [Result.failure(AnyError(error))]
            }
        } catch {
            return [Result.failure(AnyError(error))]
        }
    }

    func renderedFiles(
        urls: [URL],
        generatedfiles: [Result<Generatedfile, AnyError>],
        context: [String: Any]?
    ) -> [Result<Renderedfile, AnyError>] {
        let renderedFiles: [Result<Renderedfile, AnyError>] = generatedfiles.reduce(
            [Result<Renderedfile, AnyError>]()
        ) { (initial, next) -> [Result<Renderedfile, AnyError>] in
            var result: [Result<Renderedfile, AnyError>] = []
            switch next {
            case .success(let file):
                let filesResult = Result { try AarKayTemplates.default.render(
                    urls: urls, generatedfile: file, context: context
                ) }
                switch filesResult {
                case .success(let files):
                    result = result + files.map { Result<Renderedfile, AnyError>.success($0) }
                case .failure(let error):
                    result.append(.failure(error))
                }
            case .failure(let error):
                result.append(.failure(error))
            }
            return initial + result
        }
        return renderedFiles
    }
}
