//
//  YamlInputSerializer.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 27/02/18.
//

import Foundation
import Yams

/// Responsible for decoding Yaml file.
public final class YamlInputSerializer: InputSerializable {
    public init() {}
    public func context(at url: URL) throws -> Any? {
        let contents = try String(contentsOf: url)
        return try context(from: contents)
    }

    public func context(from contents: String) throws -> Any? {
        return try YamlInputSerializer.load(contents)
    }
}

extension YamlInputSerializer {
    public static func load(_ contents: String) throws -> Any? {
        guard !contents
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty else { return nil }
        return try Yams.load(yaml: contents)
    }
}
