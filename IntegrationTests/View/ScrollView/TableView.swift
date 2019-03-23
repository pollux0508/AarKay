//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class TableView: ScrollView {
    var tableviewModel: TableViewModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.tableviewModel = try df.dencode(type: TableViewModel.self)
        try super.init(datafile: datafile)
    }
}

public class TableViewModel: ScrollViewModel {}
