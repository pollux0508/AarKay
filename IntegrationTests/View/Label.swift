//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Label: View {
    private var model: LabelModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.model = try df.dencode(type: LabelModel.self)
        try super.init(datafile: datafile)
    }
}

public class LabelModel: ViewModel {
    public var text: String?
    public var numberOfLines: Int?
    public var font: String?
    public var textColor: String?
    public var textAlignment: String?
    public var adjustsFontSizeToFitWidth: Bool?
    public var minimumScaleFactor: Float?
    public var allowsDefaultTighteningForTruncation: Bool?

    private enum CodingKeys: String, CodingKey {
        case text
        case numberOfLines
        case font
        case textColor
        case textAlignment
        case adjustsFontSizeToFitWidth
        case minimumScaleFactor
        case allowsDefaultTighteningForTruncation
    }

    public override init(name: String) {
        super.init(name: name)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.numberOfLines = try container.decodeIfPresent(Int.self, forKey: .numberOfLines)
        self.font = try container.decodeIfPresent(String.self, forKey: .font)
        self.textColor = try container.decodeIfPresent(String.self, forKey: .textColor)
        self.textAlignment = try container.decodeIfPresent(String.self, forKey: .textAlignment)
        self.adjustsFontSizeToFitWidth = try container.decodeIfPresent(Bool.self, forKey: .adjustsFontSizeToFitWidth)
        self.minimumScaleFactor = try container.decodeIfPresent(Float.self, forKey: .minimumScaleFactor)
        self.allowsDefaultTighteningForTruncation = try container.decodeIfPresent(Bool.self, forKey: .allowsDefaultTighteningForTruncation)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(numberOfLines, forKey: .numberOfLines)
        try container.encodeIfPresent(font, forKey: .font)
        try container.encodeIfPresent(textColor, forKey: .textColor)
        try container.encodeIfPresent(textAlignment, forKey: .textAlignment)
        try container.encodeIfPresent(adjustsFontSizeToFitWidth, forKey: .adjustsFontSizeToFitWidth)
        try container.encodeIfPresent(minimumScaleFactor, forKey: .minimumScaleFactor)
        try container.encodeIfPresent(allowsDefaultTighteningForTruncation, forKey: .allowsDefaultTighteningForTruncation)
        try super.encode(to: encoder)
    }
}
