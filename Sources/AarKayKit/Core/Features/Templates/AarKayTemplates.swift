//
//  AarKayTemplates.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 01/01/18.
//

import Foundation
import Stencil
import PathKit
import StencilSwiftKit

class AarKayTemplates {
    static let `default` = AarKayTemplates()

    struct Cache {
        let environment: Environment
        let files: [String: [URL]]
    }

    private var environmentCache = Dictionary<String, Cache>()
    
    func templates(urls: [URL], name: String) throws -> ([URL], Environment) {
        let cache = try AarKayTemplates.default.cache(urls: urls)
        guard let templateUrls = cache.files[name] else {
            throw AarKayError.templateNotFound(name)
        }
        return (templateUrls, cache.environment)
    }

    private func cache(urls: [URL]) throws -> Cache {
        let cacheKey: String = urls.reduce(
            "", { (initial: String, next: URL) -> String in
                initial + next.path
            }
        )
        if let cache = environmentCache[cacheKey] { return cache }
        let env = try environment(urls: urls)
        let files = try FileManager.default.subFiles(at: urls)
        let fcs = files
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .reduce(Dictionary<String, [URL]>()) { initial, item in
                guard let name = item
                    .lastPathComponent
                    .components(separatedBy: ".")
                    .first else { return initial }
                var initial = initial
                if let value = initial[name] {
                    initial[name] = value + [item]
                } else {
                    initial[name] = [item]
                }
                return initial
            }
        let cache = Cache(environment: env, files: fcs)
        environmentCache[cacheKey] = cache
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
}
