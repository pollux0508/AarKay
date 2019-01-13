//
//  Renderedfile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 24/08/18.
//

import Foundation

public struct Renderedfile {
    public private(set) var name: String
    public private(set) var ext: String?
    public private(set) var directory: String?
    public private(set) var override: Bool
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
    
    public mutating func setName(_ name: String) {
        self.name = name.failIfEmpty()
    }
    
    public mutating func setExt(_ ext: String?) {
        self.ext = ext.nilIfEmpty()
    }
    
    public mutating func setDirectory(_ directory: String?) {
        self.directory = directory.nilIfEmpty()
    }
    
    public mutating func setOverride(_ override: Bool) {
        self.override = override
    }
}
