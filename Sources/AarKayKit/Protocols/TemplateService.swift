//
//  TemplateService.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/01/19.
//

import Foundation

/// Responsible for rendering templates.
public protocol TemplateService {
    /// The Templates
    var templates: Templates { get }

    /// Initializes the StencilProvider with Templates.
    ///
    /// - Parameter templates: The Templates.
    /// - Throws: An `Error` if intialization encouters any error.
    init(templates: Templates) throws

    /// Renders the template.
    ///
    /// - Parameters:
    ///   - name: The name of the template.
    ///   - context: The data to apply to the template.
    /// - Returns: The actual string for Generatedfile.
    /// - Throws: An `Error` if rendering template encouters any error.
    func renderTemplate(
        name: String,
        context: [String: Any]?
    ) throws -> String
}
