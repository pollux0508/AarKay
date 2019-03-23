//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Control: View {
    var controlModel: ControlModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.controlModel = try df.dencode(type: ControlModel.self)
        try super.init(datafile: datafile)
    }
}

public class ControlModel: ViewModel {}
