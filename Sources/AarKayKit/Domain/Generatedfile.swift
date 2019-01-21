//
//  Generatedfile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 24/08/18.
//

import Foundation
import SharedKit

public struct Generatedfile {
    public let name: String
    public let ext: String?
    public let directory: String?
    public let override: Bool
    public let skip: Bool
    public let contents: String

    public var nameWithExt: String {
        if let ext = self.ext {
            return name + "." + ext
        } else {
            return name
        }
    }

    init(
        name: String,
        ext: String?,
        directory: String?,
        override: Bool,
        skip: Bool,
        contents: String
    ) {
        self.name = name.failIfEmpty()
        self.ext = ext.nilIfEmpty()
        self.directory = directory.nilIfEmpty()
        self.override = override
        self.skip = skip
        self.contents = contents
    }

    public func merge(_ string: String) throws -> String {
        var template = contents
        template = try string.merge(
            template: template,
            regex: "\\n?(.*)<aarkay (.*)>([\\s\\S]*?)\\n(.*)<\\/aarkay>(.*)\\n"
        )
        template = string.append(
            template: template,
            regex: "\\n(.*) AarKayEnd"
        )
        return template
    }
}
