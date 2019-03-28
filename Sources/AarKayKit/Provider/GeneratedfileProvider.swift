//
//  GeneratedfileProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import SharedKit

struct GeneratedfileProvider: GeneratedfileService {
    func generatedfiles(
        datafiles: [Result<Datafile, Error>],
        templateService: TemplateService
    ) -> [Result<Generatedfile, Error>] {
        return datafiles.map { result -> Result<[Generatedfile], Error> in
            switch result {
            case .success(let value):
                return Result {
                    try generatedfiles(
                        datafile: value,
                        templateService: templateService
                    )
                }
            case .failure(let error):
                return .failure(error)
            }
        }.reduce(
            [Result<Generatedfile, Error>]()
        ) { (initial, next) -> [Result<Generatedfile, Error>] in
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
        datafile: Datafile,
        templateService: TemplateService
    ) throws -> [Generatedfile] {
        switch datafile.template {
        case .name(let name):
            return try generatedfiles(
                datafile: datafile,
                template: name,
                templateService: templateService
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
        datafile: Datafile,
        template: String,
        templateService: TemplateService
    ) throws -> [Generatedfile] {
        let templateUrls = try templateService.templates
            .getTemplatefile(for: template)
        guard !templateUrls.isEmpty else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .notFound(name: template)
            )
        }
        return try templateUrls.map { templateFile in
            try Try {
                let context = datafile.globalContext + datafile.context
                let rendered = try templateService.renderTemplate(
                    name: templateFile.template, context: context
                )
                return self.generatedfile(
                    datafile: datafile,
                    stringContents: rendered,
                    pathExtension: templateFile.ext
                )
            }.do { error in
                AarKayKitError.unknownError(error: error)
            }
        }
    }

    private func generatedfile(
        datafile: Datafile,
        stringContents: String,
        pathExtension: String?
    ) -> Generatedfile {
        return Generatedfile(
            datafile: datafile,
            ext: pathExtension,
            contents: stringContents
        )
    }
}
