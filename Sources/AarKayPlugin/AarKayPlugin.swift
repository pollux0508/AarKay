//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

class AarKayPlugin: Pluggable {
    public var pluginModel: AarKayPluginModel
    public var context: [String: Any]

    public required init(context: [String: Any]) throws {
        let (model, context) = try JSONCoder.dencode(
            type: AarKayPluginModel.self,
            context: context
        )
        self.pluginModel = model
        self.context = context
    }

    static func templates() -> [String] {
        var templates: [String] = []
        templates.append(#file)
        /// <aarkay templates>
        /// </aarkay>
        return templates
    }
}

public class AarKayPluginModel: Codable {
    public var plugins: [String]!
    public var isNotPlugin: Bool!
    public var swiftVersionFile: Bool!
    public var runScriptFile: Bool!
    public var swiftFormatFile: Bool!

    private enum CodingKeys: String, CodingKey {
        case plugins
        case isNotPlugin
        case swiftVersionFile
        case runScriptFile
        case swiftFormatFile
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.plugins = try container.decodeIfPresent([String].self, forKey: .plugins) ?? []
        self.isNotPlugin = try container.decodeIfPresent(Bool.self, forKey: .isNotPlugin) ?? false
        self.swiftVersionFile = try container.decodeIfPresent(Bool.self, forKey: .swiftVersionFile) ?? true
        self.runScriptFile = try container.decodeIfPresent(Bool.self, forKey: .runScriptFile) ?? true
        self.swiftFormatFile = try container.decodeIfPresent(Bool.self, forKey: .swiftFormatFile) ?? true
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plugins, forKey: .plugins)
        try container.encode(isNotPlugin, forKey: .isNotPlugin)
        try container.encode(swiftVersionFile, forKey: .swiftVersionFile)
        try container.encode(runScriptFile, forKey: .runScriptFile)
        try container.encode(swiftFormatFile, forKey: .swiftFormatFile)
    }
}

// MARK: - AarKayEnd

extension AarKayPlugin {
    func datafiles() throws -> [Datafile] {
        var datafiles: [Datafile] = []
        if pluginModel.swiftVersionFile {
            let runDatafile = Datafile(
                fileName: "run",
                directory: "scripts",
                template: .name("RunScript"),
                globalContext: context
            )
            datafiles.append(runDatafile)
        }
        if pluginModel.runScriptFile {
            let svDatafile = Datafile(
                fileName: ".swift-version",
                directory: "",
                template: .nameStringExt("SwiftVersion", "5.0.1\n", nil),
                globalContext: context
            )
            datafiles.append(svDatafile)
        }
        if pluginModel.swiftFormatFile {
            let sfDatafile = Datafile(
                fileName: ".swiftformat",
                directory: "",
                template: .name("SwiftFormat"),
                globalContext: context
            )
            datafiles.append(sfDatafile)
        }
        return datafiles
    }
}
