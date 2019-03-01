//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Template: NSObject, Templatable {
    public var datafile: Datafile
    private var model: TemplateModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: TemplateModel.self)
    }
}

public class TemplateModel: Codable {
    public var isTemplate: Bool!
    public var name: String
    public var dir: String?
    public var inputSerializer: String?
    public var customDecoder: Bool!
    public var properties: [ArgModel]!
    public var baseProperties: [ArgModel]!
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

    public var requiredBaseProperties: [ArgModel]? {
        /// <aarkay requiredBaseProperties>
        return baseProperties.filter { !$0.isOptionalOrWrapped }
        /// </aarkay>
    }

    public var requiredAllProperties: [ArgModel]? {
        /// <aarkay requiredAllProperties>
        return (baseProperties + properties).filter { !$0.isOptionalOrWrapped }
        /// </aarkay>
    }

    private enum CodingKeys: String, CodingKey {
        case isTemplate
        case name
        case dir
        case inputSerializer
        case customDecoder
        case properties
        case baseProperties
        case computedProperties
        case allProperties
        case requiredProperties
        case requiredBaseProperties
        case requiredAllProperties
    }

    public init(name: String) {
        self.name = name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isTemplate = try container.decodeIfPresent(Bool.self, forKey: .isTemplate) ?? true
        self.name = try container.decode(String.self, forKey: .name)
        self.dir = try container.decodeIfPresent(String.self, forKey: .dir)
        self.inputSerializer = try container.decodeIfPresent(String.self, forKey: .inputSerializer)
        self.customDecoder = try container.decodeIfPresent(Bool.self, forKey: .customDecoder) ?? false
        self.properties = try container.decodeIfPresent([ArgModel].self, forKey: .properties) ?? []
        self.baseProperties = try container.decodeIfPresent([ArgModel].self, forKey: .baseProperties) ?? []
        self.computedProperties = try container.decodeIfPresent([ArgModel].self, forKey: .computedProperties)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isTemplate, forKey: .isTemplate)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(dir, forKey: .dir)
        try container.encodeIfPresent(inputSerializer, forKey: .inputSerializer)
        try container.encode(customDecoder, forKey: .customDecoder)
        try container.encode(properties, forKey: .properties)
        try container.encode(baseProperties, forKey: .baseProperties)
        try container.encodeIfPresent(computedProperties, forKey: .computedProperties)
        try container.encodeIfPresent(allProperties, forKey: .allProperties)
        try container.encodeIfPresent(requiredProperties, forKey: .requiredProperties)
        try container.encodeIfPresent(requiredBaseProperties, forKey: .requiredBaseProperties)
        try container.encodeIfPresent(requiredAllProperties, forKey: .requiredAllProperties)
    }
}
