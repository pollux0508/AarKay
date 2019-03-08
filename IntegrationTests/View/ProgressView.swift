//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class ProgressView: NSObject, Templatable {
    public var datafile: Datafile
    private var model: ProgressViewModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: ProgressViewModel.self)
    }
}

public class ProgressViewModel: ViewModel {}
