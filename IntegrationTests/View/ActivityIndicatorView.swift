//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class ActivityIndicatorView: View {
    var activityindicatorviewModel: ActivityIndicatorViewModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.activityindicatorviewModel = try df.dencode(type: ActivityIndicatorViewModel.self)
        try super.init(datafile: datafile)
    }
}

public class ActivityIndicatorViewModel: ViewModel {}
