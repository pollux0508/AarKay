//
//  AarKayTemplates.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 01/01/18.
//

import Foundation
import PathKit
import Stencil
import StencilSwiftKit

private struct TemplateCache {
    let environment: Environment
    let templates: [String: [URL]]
}

class AarKayTemplates {
    static let `default` = AarKayTemplates(fileManager: FileManager.default)
    private var cache = Dictionary<String, TemplateCache>()
    let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func templatesEnvironment(urls: [URL], name: String) throws -> ([URL], Environment) {
        let cache = try templateCache(urls: urls)
        guard let templateUrls = cache.templates[name] else {
            throw AarKayError.templateNotFound(name)
        }
        return (templateUrls, cache.environment)
    }

    private func templateCache(urls: [URL]) throws -> TemplateCache {
        let cacheKey: String = urls.reduce(
            "|"
        ) { (initial: String, next: URL) -> String in
            initial + next.path + "|"
        }
        if let cache = self.cache[cacheKey] { return cache }
        let cache = TemplateCache(
            environment: try environment(urls: urls),
            templates: try templates(urls: urls)
        )
        self.cache[cacheKey] = cache
        return cache
    }

    private func environment(urls: [URL]) throws -> Environment {
        let directories = try FileManager.default.subDirectories(at: urls)
        let paths = directories.map { Path($0.path) }
        let aarkayFilesLoader = FileSystemLoader(paths: paths)
        let ext = Extension()
        ext.registerStencilSwiftExtensions()
        let environment = Environment(
            loader: aarkayFilesLoader,
            extensions: [ext],
            templateClass: StencilSwiftTemplate.self
        )
        return environment
    }
    
    private func templates(urls: [URL]) throws -> [String: [URL]] {
        let templates = try FileManager.default.subFiles(at: urls)
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .reduce(Dictionary<String, [URL]>()) { initial, item in
                let templateName = item.lastPathComponent
                let components = templateName.components(separatedBy: ".")
                guard components.count > 1 && components.count < 4 else {
                    throw AarKayError.invalidTemplate(templateName)
                }
                let name = components[0]
                guard initial[name] == nil else {
                    throw AarKayError.multipleTemplatesFound(templateName)
                }
                var initial = initial
                initial[name] = [item]
                return initial
        }
        return templates
    }
}
