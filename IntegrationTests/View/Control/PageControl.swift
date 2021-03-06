//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class PageControl: Control {
    var pagecontrolModel: PageControlModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.pagecontrolModel = try df.dencode(type: PageControlModel.self)
        try super.init(datafile: datafile)
    }
}

public class PageControlModel: ControlModel {}
