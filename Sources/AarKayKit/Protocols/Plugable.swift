//
//  Pluggable.swift
//  AarKayKit
//
//  Created by RahulKatariya on 21/01/19.
//

import Foundation

/// Represents a Plugin
public protocol Pluggable: AnyObject {
    /// The Datafile.
    var context: [String: Any] { get set }

    /// Initializes the Pluggable with the global context.
    ///
    /// - Parameter context: The global context.
    /// - Throws: An `Error` if decoding model contents encouter any error.
    init(context: [String: Any]) throws

    /// Returns the location of all templates on Disk.
    static func templates() -> [String]

    /// Returns the TemplateService object to use for rendering the template
    static func templateService() -> TemplateService.Type
}

extension Pluggable {
    /// StencilProvider
    public static func templateService() -> TemplateService.Type {
        return StencilProvider.self
    }
}
