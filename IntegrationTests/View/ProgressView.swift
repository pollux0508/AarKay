//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class ProgressView: View {
    var progressviewModel: ProgressViewModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.progressviewModel = try df.dencode(type: ProgressViewModel.self)
        try super.init(datafile: datafile)
    }
}

public class ProgressViewModel: ViewModel {}
