//
//  Renderedfile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 24/08/18.
//

import Foundation

public struct Renderedfile {
    public let name: String
    public let ext: String?
    public let directory: String?
    public let override: Bool
    public let stringBlock: (String?) -> String

    public var nameWithExt: String {
        if let ext = ext {
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
        stringBlock: @escaping (String?) -> String
    ) {
        self.name = name.failIfEmpty()
        self.ext = ext.nilIfEmpty()
        self.directory = directory.nilIfEmpty()
        self.override = override
        self.stringBlock = stringBlock
    }
}
