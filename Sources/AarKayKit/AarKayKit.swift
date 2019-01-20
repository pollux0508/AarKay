//
//  AarKayKit.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 04/12/17.
//

import Foundation
import Result

public class AarKayKit {
    let plugin: String
    let globalContext: [String: Any]?
    let globalTemplates: [URL]?
    let fileManager: FileManager
    var aarkayService: AarKayService

    public init(
        plugin: String,
        globalContext: [String: Any]?,
        globalTemplates: [URL]?,
        fileManager: FileManager = FileManager.default
    ) {
        self.plugin = plugin
        self.globalContext = globalContext
        self.globalTemplates = globalTemplates
        self.fileManager = fileManager
        let aarkayService = AarKayProvider(
            datafileService: DatafileProvider(),
            generatedfileService: GeneratedfileProvider(
//                aarkayTemplates: AarKayTemplates(
//                    templatefiles: Templatefiles,
//                    fileManager: fileManager
//                )
            )
        )
        self.aarkayService = aarkayService
    }
}

extension AarKayKit {
    public func bootstrap(
        name: String,
        directory: String?,
        template: String,
        contents: String
    ) throws -> [Result<Generatedfile, AnyError>] {
        if let templateClass = aarkayService.templateClass(
            plugin: plugin,
            template: template
        ) {
            return try bootstrap(
                templateClass: templateClass,
                name: name,
                directory: directory,
                template: template,
                contents: contents
            )
        } else {
            guard let globalTempaltes = globalTemplates else {
                throw AarKayError.invalidTemplate(
                    AarKayError.InvalidTemplateReason.notFound
                )
            }
            let templatesUrls = try templates(urls: globalTempaltes)
            
            let templatefiles = Templatefiles(
                urls: globalTempaltes,
                files: templatesUrls
            )

            let datafiles = try aarkayService.datafileService.serialize(
                plugin: plugin,
                name: name,
                template: template,
                contents: contents,
                globalContext: globalContext,
                using: YamlInputSerializer()
            )

            return aarkayService.generatedfileService.generatedfiles(
                templatefiles: templatefiles,
                datafiles: datafiles,
                globalContext: globalContext
            )
        }
    }

    func bootstrap(
        templateClass: Templatable.Type,
        name: String,
        directory: String?,
        template: String,
        contents: String
    ) throws -> [Result<Generatedfile, AnyError>] {
        let templatesDir = try templatesDirectory(urls: templateClass.templates())
        let templatesUrls = try templates(urls: templatesDir)
        let templatefiles = Templatefiles(
            urls: templatesDir,
            files: templatesUrls
        )
        
        aarkayService.generatedfileService.aarkayTemplates = try AarKayTemplates(
            templatefiles: templatefiles,
            fileManager: fileManager
        )
        
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
            templatefiles: templatefiles,
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
                        "Incorrect plugin structure at \($0)"
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
    
    fileprivate func templates(urls: [URL]) throws -> [String: [URL]] {
        let templates = try fileManager.subFiles(at: urls)
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .reduce(Dictionary<String, [URL]>()) { initial, item in
                let templateFile = try Templatefile(name: item.lastPathComponent)
                guard initial[templateFile.template] == nil else {
                    throw AarKayError.invalidTemplate(
                        AarKayError.InvalidTemplateReason.mutipleFound
                    )
                }
                var initial = initial
                initial[templateFile.template] = [item]
                return initial
        }
        return templates
    }
}
