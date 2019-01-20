//
//  Templatefile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 21/01/19.
//

import Foundation

struct Templatefiles {
    let urls: [URL]
    let files: [String: [URL]]
}

struct Templatefile {
    let name: String
    let template: String
    let ext: String?
    let type: String

    init(name: String) throws {
        let fc = name.components(separatedBy: ".")
        guard fc.count > 1 && fc.count <= 3 else {
            throw AarKayError.invalidTemplate(
                AarKayError.InvalidTemplateReason.invalidName
            )
        }
        self.name = name
        self.template = fc[0]
        self.ext = fc.count == 3 ? fc[1] : nil
        self.type = fc.count == 3 ? fc[2] : fc[1]
    }
}
