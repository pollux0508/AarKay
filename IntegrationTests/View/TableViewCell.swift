//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class TableViewCell: View {
    var tableviewcellModel: TableViewCellModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.tableviewcellModel = try df.dencode(type: TableViewCellModel.self)
        try super.init(datafile: datafile)
    }
}

public class TableViewCellModel: ViewModel {}
