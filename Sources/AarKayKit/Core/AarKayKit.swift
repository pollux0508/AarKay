//
//  AarKayKit.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 09/03/19.
//

import Foundation

public class AarKayKit {
    /// Creates the Pluggable Type at runtime from the plugin name.
    ///
    /// - Parameter plugin: The name of the plugin.
    /// - Returns: The Pluggable Type.
    /// - Throws: An `Error` if pluggable class could not be created.
    public static func pluggableClass(
        plugin: String
    ) throws -> Pluggable.Type? {
        guard plugin.lowercased() != "noplugin" else { return nil }
        if let plugableClass = NSClassFromString(
            "aarkay_plugin_\(plugin.lowercased()).AarKayPlugin"
        ) as? Pluggable.Type {
            return plugableClass
        } else if let plugableClass = NSClassFromString(
            "\(plugin).AarKayPlugin"
        ) as? Pluggable.Type {
            return plugableClass
        } else {
            throw AarKayKitError.invalidPlugin(name: plugin)
        }
    }

    /// Creates the Templatable Type at runtime from the plugin and template name.
    ///
    /// - Parameters:
    ///   - plugin: The plugin name.
    ///   - template: The template name.
    /// - Returns: The Templatable Type.
    public static func templateClass(
        plugin: String,
        template: String
    ) -> Templatable.Type? {
        if let templateClass = NSClassFromString(
            "\(plugin).\(template)"
        ) as? Templatable.Type {
            return templateClass
        } else if let templateClass = NSClassFromString(
            "aarkay_plugin_\(plugin.lowercased()).\(template)"
        ) as? Templatable.Type {
            return templateClass
        } else {
            return nil
        }
    }
}
