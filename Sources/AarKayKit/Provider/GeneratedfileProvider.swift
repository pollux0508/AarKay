//
//  GeneratedfileProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import Result

struct GeneratedfileProvider: GeneratedfileService {
    let aarkayTemplates: AarKayTemplates

    func generatedfiles(
        urls: [URL],
        datafiles: [Result<Datafile, AnyError>],
        globalContext: [String: Any]?
    ) -> [Result<Generatedfile, AnyError>] {
        return datafiles.map { result -> Result<[Generatedfile], AnyError> in
            switch result {
            case .success(let value):
                return Result {
                    return try generatedfiles(
                        urls: urls, datafile: value, globalContext: globalContext
                    )
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
    private func generatedfiles(
        urls: [URL],
        datafile: Datafile,
        globalContext: [String: Any]?
    ) throws -> [Generatedfile] {
        switch datafile.template {
        case .name(let name):
            return try generatedfiles(
                urls: urls,
                datafile: datafile,
                template: name,
                context: datafile.globalContext + datafile.context
            )
        case .nameStringExt(_, let string, let ext):
            let file = generatedfile(
                datafile: datafile,
                stringContents: string,
                pathExtension: ext
            )
            return [file]
        }
    }

    private func generatedfiles(
        urls: [URL],
        datafile: Datafile,
        template: String,
        context: [String: Any]? = nil
    ) throws -> [Generatedfile] {
        let (templates, environment) = try aarkayTemplates
            .templatesEnvironment(urls: urls, name: template)
        return try templates.map { templateUrl in
            let (name, ext) = try templateUrl.template()
            return try Try {
                let rendered = try environment.renderTemplate(
                    name: name, context: context
                )
                return self.generatedfile(
                    datafile: datafile,
                    stringContents: rendered,
                    pathExtension: ext
                )
            }.catchMapError { _ in
                AarKayError.templateNotFound(template)
            }
        }
    }

    private func generatedfile(
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

extension URL {
    fileprivate func template() throws -> (String, String?) {
        let name = lastPathComponent
        let fc = name.components(separatedBy: ".")
        guard fc.count > 1 && fc.count <= 3 else { throw AarKayError.invalidTemplate(name) }
        let templateName = fc.joined(separator: ".")
        let ext = fc.count == 3 ? fc[1] : nil
        return (templateName, ext)
    }
}
