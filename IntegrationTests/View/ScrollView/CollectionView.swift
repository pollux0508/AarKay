//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class CollectionView: ScrollView {
    var collectionviewModel: CollectionViewModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.collectionviewModel = try df.dencode(type: CollectionViewModel.self)
        try super.init(datafile: datafile)
    }
}

public class CollectionViewModel: ScrollViewModel {}
