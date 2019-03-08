//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Switch: Control {
    private var model: SwitchModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.model = try df.dencode(type: SwitchModel.self)
        try super.init(datafile: datafile)
    }
}

public class SwitchModel: ControlModel {}
