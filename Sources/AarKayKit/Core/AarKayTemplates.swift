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
        let files: [String: URL]
    }

    private var environmentCache = Dictionary<String, Cache>()

    func render(urls: [URL], generatedfile: Generatedfile, context: [String: Any]?) throws -> Renderedfile {
        var stringContents: String!
        var pathExtension: String = generatedfile.ext ?? ""

        if let templateString = generatedfile.templateString {
            stringContents = templateString
        } else {
            let (string, ext) = try AarKayTemplates.default.renderTemplate(
                urls: urls,
                name: generatedfile.template,
                context: context + generatedfile.contents
            )
            stringContents = string
            pathExtension = ext
        }

        let fileName = pathExtension.isEmpty ? generatedfile.name : generatedfile.name + "." + pathExtension
        let file = Renderedfile(fileName: fileName, directory: generatedfile.directory, override: generatedfile.override) {
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
    ) throws -> (String, String) {
        let cache = self.cache(urls: urls)
        guard let templateUrl = cache.files[name] else { throw AarKayError.templateNotFound(name) }
        if let (templateName, ext) = try templateUrl.rk.template() {
            let rendered = try cache.environment.renderTemplate(
                name: templateName, context: context
            )
            return (rendered, ext)
        } else {
            let rendered = try cache.environment.renderTemplate(
                name: name, context: context
            )
            return (rendered, "")
        }
    }

    private func cache(urls: [URL]) -> Cache {
        let cacheKey: String = urls.reduce("", { (initial: String, next: URL) -> String in
            return initial + next.path
        })
        if let cache = environmentCache[cacheKey] { return cache }
        let env = urls.rk.environment()
        let files = FileManager.default.subFiles(atUrls: urls) ?? []
        let fcs = files.filter { !$0.lastPathComponent.hasPrefix(".") }
            .reduce(Dictionary<String, URL>()) { initial, item in
                guard let name = item.lastPathComponent.components(separatedBy: ".").first else { return initial }
                var initial = initial
                initial[name] = item
                return initial
            }
        let cache = Cache(environment: env, files: fcs)
        environmentCache[cacheKey] = cache
        return cache
    }
}
