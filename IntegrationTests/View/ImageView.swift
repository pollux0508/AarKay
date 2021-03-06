//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class ImageView: View {
    var imageviewModel: ImageViewModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.imageviewModel = try df.dencode(type: ImageViewModel.self)
        try super.init(datafile: datafile)
    }
}

public class ImageViewModel: ViewModel {
    public var contentMode: String?

    private enum CodingKeys: String, CodingKey {
        case contentMode
    }

    public override init(
        name: String,
        useNib: Bool = false,
        prefix: String = "UI"
    ) {
        super.init(
            name: name,
            useNib: useNib,
            prefix: prefix
        )
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contentMode = try container.decodeIfPresent(String.self, forKey: .contentMode)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(contentMode, forKey: .contentMode)
        try super.encode(to: encoder)
    }
}
