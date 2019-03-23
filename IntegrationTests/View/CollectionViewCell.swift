//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class CollectionViewCell: View {
    var collectionviewcellModel: CollectionViewCellModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.collectionviewcellModel = try df.dencode(type: CollectionViewCellModel.self)
        try super.init(datafile: datafile)
    }
}

public class CollectionViewCellModel: ViewModel {}
