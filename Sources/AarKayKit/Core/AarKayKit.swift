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
        globalTemplates: Set<URL>?
    ) throws -> [Result<Generatedfile, AnyError>] {
        let aarkayService = AarKayProvider(
            datafileService: DatafileProvider(),
            generatedfileService: GeneratedfileProvider()
        )

        let aarkayKit = AarKayKit(
            plugin: plugin,
            name: fileName,
            directory: directory,
            template: template,
            contents: contents,
            globalContext: globalContext,
            globalTemplates: globalTemplates != nil ? Array(globalTemplates!) : nil,
            aarkayService: aarkayService
        )

        return try aarkayKit.bootstrap()
    }
}

extension AarKayKit {
    func bootstrap() throws -> [Result<Generatedfile, AnyError>] {
        if let templateClass = aarkayService.templateClass(
            plugin: plugin,
            template: template
        ) {
            return try bootstrap(templateClass: templateClass)
        } else {
            guard let globalTempaltes = globalTemplates else {
                throw AarKayError.templateNotFound(template)
            }

            let datafiles = try aarkayService.datafileService.serialize(
                plugin: plugin,
                name: name,
                template: template,
                contents: contents,
                globalContext: globalContext,
                using: YamlInputSerializer()
            )

            return aarkayService.generatedfileService.generatedfiles(
                urls: globalTempaltes,
                datafiles: datafiles,
                globalContext: globalContext
            )
        }
    }

    func bootstrap(templateClass: Templatable.Type) throws -> [Result<Generatedfile, AnyError>] {
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
                    let datafiles = aarkayService.datafileService
                        .templateDatafiles(
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

        return aarkayService.generatedfileService.generatedfiles(
            urls: try templatesDirectory(urls: templateClass.templates()),
            datafiles: templateDatafiles,
            globalContext: globalContext
        )
    }
}

// MARK: - Private Helpers
extension AarKayKit {
    fileprivate func templatesDirectory(urls: [String]) throws -> [URL] {
        return try urls.map {
            var url = URL(fileURLWithPath: $0)
            while url.lastPathComponent != "Sources" {
                if url.lastPathComponent == "/" {
                    throw AarKayError.internalError(
                        "Failed to fetch Templates directory for \($0)"
                    )
                }
                url = url.deletingLastPathComponent()
            }
            url = url
                .deletingLastPathComponent()
                .appendingPathComponent(
                    "AarKay/AarKayTemplates",
                    isDirectory: true
            )
            if url.path.hasPrefix("/tmp") {
                print("[OLD]", url.absoluteString)
                let pathComponents = Array(url.pathComponents.dropFirst().dropFirst())
                let newPath = "/" + pathComponents.joined(separator: "/")
                url = URL(fileURLWithPath: newPath, isDirectory: true)
                print("[NEW]", url.absoluteString)
            }
            return url
        }
    }
}
