//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import aarkay_plugin_aarkay
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

public class AarKayPluginModel: Codable {}
