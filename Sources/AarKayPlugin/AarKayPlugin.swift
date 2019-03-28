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
    public var name: String
    public var isNotPlugin: Bool!

    private enum CodingKeys: String, CodingKey {
        case name
        case isNotPlugin
    }

    public init(
        name: String
    ) {
        self.name = name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.isNotPlugin = try container.decodeIfPresent(Bool.self, forKey: .isNotPlugin) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
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
            template: .nameStringExt("SwiftVersion", "5.0\n", nil),
            globalContext: context
        )
        return [
            runDatafile,
            svDatafile,
        ]
    }
}
