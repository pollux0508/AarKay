//
//  Plugable.swift
//  AarKayKit
//
//  Created by RahulKatariya on 21/01/19.
//

import Foundation

/// Represents a Plugin
public protocol Plugable: class {
    /// Returns the location of all templates on Disk.
    static func templates() -> [String]

    /// Returns the TemplateService object to use for rendering the template
    static func templateService() -> TemplateService.Type
}

extension Plugable {
    /// StencilProvider
    public static func templateService() -> TemplateService.Type {
        return StencilProvider.self
    }
}
