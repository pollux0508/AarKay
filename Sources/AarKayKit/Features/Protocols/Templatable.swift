//
//  Templatable.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 29/12/17.
//

import Foundation

public protocol Templatable: class {
    var datafile: Datafile { get set }

    init(datafile: Datafile) throws
    func datafiles() throws -> [Datafile]

    static func templates() -> [String]
    static func inputSerializer() -> InputSerializable
}

extension Templatable {
    public func datafiles() throws -> [Datafile] {
        return [datafile]
    }

    public static func inputSerializer() -> InputSerializable {
        return YamlInputSerializer()
    }
}
