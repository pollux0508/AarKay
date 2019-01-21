//
//  Plugable.swift
//  AarKayKit
//
//  Created by RahulKatariya on 21/01/19.
//

import Foundation

public protocol Plugable: class {
    static func templates() -> [String]
    static func templateService() -> TemplateService.Type
}

extension Plugable {
    public static func templateService() -> TemplateService.Type {
        return StencilProvider.self
    }
}
