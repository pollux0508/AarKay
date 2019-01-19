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
        let cache = try self.cache(urls: urls)
        guard let templateUrls = cache.files[name] else { throw AarKayError.templateNotFound(name) }
        var result: [(String, String?)] = []
        try templateUrls.forEach { templateUrl in
            let (name, ext) = try templateUrl.rk.template()
            let rendered = try cache.environment.renderTemplate(
                name: name, context: context
            )
            result.append((rendered, ext))
        }
        return result
    }

    private func cache(urls: [URL]) throws -> Cache {
        let cacheKey: String = urls.reduce(
            "", { (initial: String, next: URL) -> String in
                initial + next.path
            }
        )
        if let cache = environmentCache[cacheKey] { return cache }
        let env = try urls.rk.environment()
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
}
