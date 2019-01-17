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

    func renderTemplate(
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
        let fcs = files
            .filter { !$0.lastPathComponent.hasPrefix(".") }
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
