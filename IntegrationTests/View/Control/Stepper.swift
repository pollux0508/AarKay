//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Stepper: Control {
    var stepperModel: StepperModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.stepperModel = try df.dencode(type: StepperModel.self)
        try super.init(datafile: datafile)
    }
}

public class StepperModel: ControlModel {}
