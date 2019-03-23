//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class SegmentedControl: Control {
    var segmentedcontrolModel: SegmentedControlModel

    public required init(datafile: Datafile) throws {
        var df = datafile
        self.segmentedcontrolModel = try df.dencode(type: SegmentedControlModel.self)
        try super.init(datafile: datafile)
    }
}

public class SegmentedControlModel: ControlModel {}
