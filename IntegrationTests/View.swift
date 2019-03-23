//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class View: NSObject, Templatable {
    public var datafile: Datafile
    var viewModel: ViewModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.viewModel = try self.datafile.dencode(type: ViewModel.self)
    }
}

public class ViewModel: Codable {
    public var name: String
    public var context: [ArgModel]?
    public var useNib: Bool!
    public var prefix: String!

    private enum CodingKeys: String, CodingKey {
        case name
        case context
        case useNib
        case prefix
    }

    public init(
        name: String, 
        useNib: Bool = false, 
        prefix: String = "UI"
    ) {
        self.name = name
        self.useNib = useNib
        self.prefix = prefix
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.context = try container.decodeIfPresent([ArgModel].self, forKey: .context)
        self.useNib = try container.decodeIfPresent(Bool.self, forKey: .useNib) ?? false
        self.prefix = try container.decodeIfPresent(String.self, forKey: .prefix) ?? "UI"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(context, forKey: .context)
        try container.encode(useNib, forKey: .useNib)
        try container.encode(prefix, forKey: .prefix)
    }
}
