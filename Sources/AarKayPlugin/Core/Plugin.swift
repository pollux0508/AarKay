//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Plugin: NSObject, Templatable {
    public var datafile: Datafile
    var pluginModel: PluginModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.pluginModel = try self.datafile.dencode(type: PluginModel.self)
    }
}

public class PluginModel: Codable {
    public var properties: [ArgModel]!
    public var computedProperties: [ArgModel]?

    public var allProperties: [ArgModel]? {
        /// <aarkay allProperties>
        let props = properties ?? []
        let cProps = computedProperties ?? []
        let allProperties = props + cProps
        return allProperties.isEmpty ? nil : allProperties
        /// </aarkay>
    }

    public var requiredProperties: [ArgModel]? {
        /// <aarkay requiredProperties>
        return properties.filter { !$0.isOptionalOrWrapped }
        /// </aarkay>
    }

    public var requiredAllProperties: [ArgModel]? {
        /// <aarkay requiredAllProperties>
        return properties.filter { !$0.isOptionalOrWrapped }
        /// </aarkay>
    }

    private enum CodingKeys: String, CodingKey {
        case properties
        case computedProperties
        case allProperties
        case requiredProperties
        case requiredAllProperties
    }

    public init(
        properties: [ArgModel] = []
    ) {
        self.properties = properties
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.properties = try container.decodeIfPresent([ArgModel].self, forKey: .properties) ?? []
        self.computedProperties = try container.decodeIfPresent([ArgModel].self, forKey: .computedProperties)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(properties, forKey: .properties)
        try container.encodeIfPresent(computedProperties, forKey: .computedProperties)
        try container.encodeIfPresent(allProperties, forKey: .allProperties)
        try container.encodeIfPresent(requiredProperties, forKey: .requiredProperties)
        try container.encodeIfPresent(requiredAllProperties, forKey: .requiredAllProperties)
    }
}

// MARK: - AarKayEnd

extension Plugin {
    public func datafiles() throws -> [Datafile] {
        datafile.setFileName("AarKayPlugin")
        try datafile.setContext(pluginModel, with: ["name": "AarKayPlugin"])
        return [datafile]
    }
}
