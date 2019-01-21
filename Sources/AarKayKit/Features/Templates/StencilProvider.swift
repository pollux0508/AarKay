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

class StencilProvider: TemplateService {
    let templatefiles: Templatefiles
    var environment: Environment!

    required init(
        templatefiles: Templatefiles
    ) throws {
        self.templatefiles = templatefiles
        self.environment = {
            let paths = templatefiles.directories.map { Path($0.path) }
            let aarkayFilesLoader = FileSystemLoader(paths: paths)
            let ext = Extension()
            ext.registerStencilSwiftExtensions()
            let environment = Environment(
                loader: aarkayFilesLoader,
                extensions: [ext],
                templateClass: StencilSwiftTemplate.self
            )
            return environment
        }()
    }

    func renderTemplate(
        name: String,
        context: [String: Any]?
    ) throws -> String {
        return try environment.renderTemplate(
            name: name, context: context
        )
    }
}
