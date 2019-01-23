//
//  TemplateService.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/01/19.
//

import Foundation

public protocol TemplateService {
    var templates: Templates { get }

    init(templates: Templates) throws

    func renderTemplate(
        name: String,
        context: [String: Any]?
    ) throws -> String
}
