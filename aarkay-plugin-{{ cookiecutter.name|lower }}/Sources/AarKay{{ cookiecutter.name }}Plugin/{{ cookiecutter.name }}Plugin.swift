//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

class {{ cookiecutter.name }}Plugin: Plugable {
    public var context: [String: Any]

    public required init(context: [String: Any]) throws {
        self.context = try JSONCoder.dencode(
            type: {{ cookiecutter.name }}PluginModel.self,
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

public class {{ cookiecutter.name }}PluginModel: Codable {}
