//
//  AarKayTemplates.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 01/01/18.
//

import Foundation
import Stencil

class AarKayTemplates {
    static let `default` = AarKayTemplates()

    struct Cache {
        let environment: Environment
        let files: [String: [URL]]
    }

    private var environmentCache = Dictionary<String, Cache>()

    func render(
        urls: [URL],
        generatedfile: Generatedfile,
        context: [String: Any]?
    ) throws -> [Renderedfile] {
        if let templateString = generatedfile.templateString {
            let file = renderedFile(
                generatedfile: generatedfile,
                stringContents: templateString,
                pathExtension: generatedfile.ext
            )
            return [file]
        } else {
            let templates = try AarKayTemplates.default.renderTemplate(
                urls: urls,
                name: generatedfile.template,
                context: context + generatedfile.contents
            )
            return templates.map {
                renderedFile(
                    generatedfile: generatedfile,
                    stringContents: $0.0,
                    pathExtension: $0.1
                )
            }
        }
    }

    private func renderedFile(
        generatedfile: Generatedfile,
        stringContents: String,
        pathExtension: String?
    ) -> Renderedfile {
        let file = Renderedfile(
            name: generatedfile.name,
            ext: pathExtension,
            directory: generatedfile.directory,
            override: generatedfile.override
        ) {
            if let currentString = $0 {
                return currentString.rk.merge(templateString: stringContents)
            } else {
                return stringContents
            }
        }
        return file
    }

    private func renderTemplate(
        urls: [URL],
        name: String,
        context: [String: Any]? = nil
    ) throws -> [(String, String?)] {
        let cache = self.cache(urls: urls)
        guard let templateUrls = cache.files[name] else { throw AarKayError.templateNotFound(name) }
        var result: [(String, String?)] = []
        try templateUrls.forEach { templateUrl in
            if let (templateName, ext) = try templateUrl.rk.template() {
                let rendered = try cache.environment.renderTemplate(
                    name: templateName, context: context
                )
                result.append((rendered, ext))
            } else {
                let rendered = try cache.environment.renderTemplate(
                    name: name, context: context
                )
                result.append((rendered, nil))
            }
        }
        return result
    }

    private func cache(urls: [URL]) -> Cache {
        let cacheKey: String = urls.reduce(
            "", { (initial: String, next: URL) -> String in
                initial + next.path
            }
        )
        if let cache = environmentCache[cacheKey] { return cache }
        let env = urls.rk.environment()
        let files = FileManager.default.subFiles(atUrls: urls) ?? []
        let fcs = files.filter { !$0.lastPathComponent.hasPrefix(".") }
            .reduce(Dictionary<String, [URL]>()) { initial, item in
                guard let name = item.lastPathComponent.components(separatedBy: ".").first else { return initial }
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
}
