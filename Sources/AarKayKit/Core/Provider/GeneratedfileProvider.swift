//
//  GeneratedfileProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import Result

struct GeneratedfileProvider: GeneratedfileService {
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
    ) -> [Result<Generatedfile, AnyError>] {
        return datafiles.map { result -> Result<[Generatedfile], AnyError> in
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
            [Result<Generatedfile, AnyError>]()
        ) { (initial, next) -> [Result<Generatedfile, AnyError>] in
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

extension GeneratedfileProvider {
    private func generatedFiles(
        urls: [URL],
        datafile: Datafile,
        globalContext: [String: Any]?
    ) throws -> [Generatedfile] {
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
    ) -> Generatedfile {
        return Generatedfile(
            name: datafile.fileName,
            ext: pathExtension,
            directory: datafile.directory,
            override: datafile.override,
            skip: datafile.skip,
            contents: stringContents
        )
    }
}
