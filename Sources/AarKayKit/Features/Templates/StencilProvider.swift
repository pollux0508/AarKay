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

/// Responsible for rendering stencil templates.
class StencilProvider: TemplateService {
    let templates: Templates
    private var environment: Environment!

    required init(
        templates: Templates
    ) {
        self.templates = templates
        self.environment = {
            let paths = templates.directories.map { Path($0.path) }
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
