//
//  GeneratedfileProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import Result

struct GeneratedfileProvider: GeneratedfileService {
    
    var aarkayTemplates: AarKayTemplates?
    
    init() {}

    func generatedfiles(
        templatefiles: Templatefiles,
        datafiles: [Result<Datafile, AnyError>],
        globalContext: [String: Any]?
    ) -> [Result<Generatedfile, AnyError>] {
        return datafiles.map { result -> Result<[Generatedfile], AnyError> in
            switch result {
            case .success(let value):
                return Result {
                    try generatedfiles(
                        templatefiles: templatefiles,
                        datafile: value,
                        globalContext: globalContext
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
        templatefiles: Templatefiles,
        datafile: Datafile,
        globalContext: [String: Any]?
    ) throws -> [Generatedfile] {
        switch datafile.template {
        case .name(let name):
            return try generatedfiles(
                templatefiles: templatefiles,
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
        templatefiles: Templatefiles,
        datafile: Datafile,
        template: String,
        context: [String: Any]? = nil
    ) throws -> [Generatedfile] {
        guard let templateUrls = templatefiles.files[template] else {
            throw AarKayError.invalidTemplate(
                AarKayError.InvalidTemplateReason.notFound
            )
        }
        let files = try templateUrls.map {
            try Templatefile(name: $0.lastPathComponent)
        }
        return try files.map { templateFile in
            return try Try {
                let rendered = try self.aarkayTemplates!.renderTemplate(
                    name: templateFile.name, context: context
                )
                return self.generatedfile(
                    datafile: datafile,
                    stringContents: rendered,
                    pathExtension: templateFile.ext
                )
            }.catchMapError { _ in
                AarKayError.invalidTemplate(
                    AarKayError.InvalidTemplateReason.notFound
                )
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
