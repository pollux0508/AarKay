//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

class AarKayPluginPlugin: Plugable {
    public var context: [String: Any]

    public required init(context: [String: Any]) throws {
        self.context = try JSONCoder.dencode(type: AarKayPluginPluginModel.self, context: context)
    }

    static func templates() -> [String] {
        var templates: [String] = []
        templates.append(#file)
        /// <aarkay templates>
        /// </aarkay>
        return templates
    }
}

public class AarKayPluginPluginModel: Codable {
    public var isNotPlugin: Bool!

    private enum CodingKeys: String, CodingKey {
        case isNotPlugin
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isNotPlugin = try container.decodeIfPresent(Bool.self, forKey: .isNotPlugin) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isNotPlugin, forKey: .isNotPlugin)
    }
}
