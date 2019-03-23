//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class ScrollView: View {
    var scrollviewModel: ScrollViewModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.scrollviewModel = try df.dencode(type: ScrollViewModel.self)
        try super.init(datafile: datafile)
    }
}

public class ScrollViewModel: ViewModel {}
