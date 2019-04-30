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
    public var context: [String: Any]

    public required init(context: [String: Any]) throws {
        self.context = try JSONCoder.dencode(
            type: AarKayPluginModel.self,
            context: context
        )
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

    private enum CodingKeys: String, CodingKey {
        case plugins
        case isNotPlugin
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.plugins = try container.decodeIfPresent([String].self, forKey: .plugins) ?? []
        self.isNotPlugin = try container.decodeIfPresent(Bool.self, forKey: .isNotPlugin) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plugins, forKey: .plugins)
        try container.encode(isNotPlugin, forKey: .isNotPlugin)
    }
}

// MARK: - AarKayEnd

extension AarKayPlugin {
    func datafiles() throws -> [Datafile] {
        let runDatafile = Datafile(
            fileName: "run",
            directory: "scripts",
            template: .name("RunScript"),
            globalContext: context
        )
        let svDatafile = Datafile(
            fileName: ".swift-version",
            directory: "",
            template: .nameStringExt("SwiftVersion", "5.0.1\n", nil),
            globalContext: context
        )
        return [
            runDatafile,
            svDatafile,
        ]
    }
}
