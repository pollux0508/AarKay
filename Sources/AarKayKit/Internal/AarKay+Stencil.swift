//
//  AarKay+URL.swift
//  AarKayKit
//
//  Created by RahulKatariya on 29/08/18.
//

import Foundation
import PathKit
import Stencil
import StencilSwiftKit

extension URL: AarKayExtensionsProvider {}

extension AarKay where Base == URL {
    func environment() throws -> Environment {
        return try [base].rk.environment()
    }

    func template() throws -> (String, String?) {
        let name = base.lastPathComponent
        let fc = name.components(separatedBy: ".")
        guard fc.count > 1 && fc.count <= 3 else { throw AarKayError.invalidTemplate(name) }
        let templateName = fc.joined(separator: ".")
        let ext = fc.count == 3 ? fc[1] : nil
        return (templateName, ext)
    }
}

extension Array: AarKayExtensionsProvider where Element == URL {}

extension AarKay where Base == [URL] {
    func environment() throws -> Environment {
        let directories = try FileManager.default.subDirectories(at: base)
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

    func templatesDirectory() -> [URL] {
        return base.map {
            var url = $0
            while url.lastPathComponent != "Sources" {
                url = url.deletingLastPathComponent()
            }
            url = url
                .deletingLastPathComponent()
                .appendingPathComponent(
                    "AarKay/AarKayTemplates", isDirectory: true
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
