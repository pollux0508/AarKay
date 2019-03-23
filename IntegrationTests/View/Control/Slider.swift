//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Slider: Control {
    var sliderModel: SliderModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.sliderModel = try df.dencode(type: SliderModel.self)
        try super.init(datafile: datafile)
    }
}

public class SliderModel: ControlModel {}
