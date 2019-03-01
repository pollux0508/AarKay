//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class StackViewModel: Codable {
    public var axis: String?
    public var distribution: String?
    public var alignment: String?
    public var spacing: Float?
    public var isBaselineRelativeArrangement: Bool?
    public var isLayoutMarginsRelativeArrangement: Bool?
    public var asv: [String]?

    private enum CodingKeys: String, CodingKey {
        case axis
        case distribution
        case alignment
        case spacing
        case isBaselineRelativeArrangement
        case isLayoutMarginsRelativeArrangement
        case asv
    }

    public init(name: String) {
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.axis = try container.decodeIfPresent(String.self, forKey: .axis)
        self.distribution = try container.decodeIfPresent(String.self, forKey: .distribution)
        self.alignment = try container.decodeIfPresent(String.self, forKey: .alignment)
        self.spacing = try container.decodeIfPresent(Float.self, forKey: .spacing)
        self.isBaselineRelativeArrangement = try container.decodeIfPresent(Bool.self, forKey: .isBaselineRelativeArrangement)
        self.isLayoutMarginsRelativeArrangement = try container.decodeIfPresent(Bool.self, forKey: .isLayoutMarginsRelativeArrangement)
        self.asv = try container.decodeIfPresent([String].self, forKey: .asv)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(axis, forKey: .axis)
        try container.encodeIfPresent(distribution, forKey: .distribution)
        try container.encodeIfPresent(alignment, forKey: .alignment)
        try container.encodeIfPresent(spacing, forKey: .spacing)
        try container.encodeIfPresent(isBaselineRelativeArrangement, forKey: .isBaselineRelativeArrangement)
        try container.encodeIfPresent(isLayoutMarginsRelativeArrangement, forKey: .isLayoutMarginsRelativeArrangement)
        try container.encodeIfPresent(asv, forKey: .asv)
    }
}

