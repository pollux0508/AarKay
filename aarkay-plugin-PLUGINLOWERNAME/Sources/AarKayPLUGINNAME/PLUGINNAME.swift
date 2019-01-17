//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import AarKayPlugin
import Foundation

public class PLUGINNAME: NSObject, Templatable {
    public var datafile: Datafile
    private var model: PLUGINNAMEModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: PLUGINNAMEModel.self)
    }

    public static func templates() -> [String] {
        var templates: [String] = []
        templates.append(#file)
        /// <aarkay templatesPLUGINNAME>
        /// </aarkay>
        return templates
    }
}

public class PLUGINNAMEModel: Codable {
    public var name: String

    private enum CodingKeys: String, CodingKey {
        case name
    }

    public init(name: String) {
        self.name = name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
