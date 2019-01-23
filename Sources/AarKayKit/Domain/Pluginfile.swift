//
//  Pluginfile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/01/19.
//

import Foundation

/// Represents an AarKayPlugin
struct Pluginfile {
    /// The name of the plugin.
    let name: String

    /// The global context applied to all templates.
    let globalContext: [String: Any]?

    /// The global templates paths to use if plugin doesn't exist.
    let globalTemplates: [URL]?
}
