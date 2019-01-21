//
//  AarKayProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/10/18.
//

import Foundation
import Result

struct AarKayProvider: AarKayService {
    var pluginfileService: PluginfileService
    var datafileService: DatafileService
    var generatedfileService: GeneratedfileService
}
