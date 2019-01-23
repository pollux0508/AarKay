//
//  Templatefile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 21/01/19.
//

import Foundation

struct Templatefile {
    let template: String
    let name: String
    let ext: String?
    let type: String

    init(template: String) throws {
        let fc = template.components(separatedBy: ".")
        guard fc.count > 1 && fc.count <= 3 else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .invalidName(name: template)
            )
        }
        self.template = template
        self.name = fc[0]
        self.ext = fc.count == 3 ? fc[1] : nil
        self.type = fc.count == 3 ? fc[2] : fc[1]
    }
}
