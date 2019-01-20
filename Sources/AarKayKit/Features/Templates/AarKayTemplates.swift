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

class AarKayTemplates {
    let templatefiles: Templatefiles
    let directories: [URL]
    let fileManager: FileManager
    
    lazy var environment: Environment = {
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
    }()

    init(
        templatefiles: Templatefiles,
        fileManager: FileManager
    ) throws {
        self.templatefiles = templatefiles
        self.fileManager = fileManager
        self.directories = try fileManager.subDirectories(at: templatefiles.urls)
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
