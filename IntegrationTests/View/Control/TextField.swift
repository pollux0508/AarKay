//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class TextField: Control {
    private var model: TextFieldModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.model = try df.dencode(type: TextFieldModel.self)
        try super.init(datafile: datafile)
    }
}

public class TextFieldModel: ControlModel {}
