//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Button: Control {
    var buttonModel: ButtonModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.buttonModel = try df.dencode(type: ButtonModel.self)
        try super.init(datafile: datafile)
    }
}

public class ButtonModel: ControlModel {}
