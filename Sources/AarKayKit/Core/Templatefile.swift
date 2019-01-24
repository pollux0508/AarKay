//
//  Templatefile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 21/01/19.
//

import Foundation

/// Represents a Templatefile.
struct Templatefile {
    /// The template file name.
    let template: String

    /// The name of the template.
    let name: String

    /// The extension of the datafile.
    let ext: String?

    /// Initializes a Templatefile.
    ///
    /// - Parameter template: The template file name.
    /// - Throws: An `Error` if the template file name is invalid.
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
    }
}
