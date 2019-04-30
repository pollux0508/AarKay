//
//  InputSerializable.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 27/02/18.
//

import Foundation

/// Responsible for decoding the contents.
public protocol InputSerializable {
    /// Read the contents of the file.
    func contents(at url: URL) throws -> String

    /// Decodes the contents to Swift object.
    ///
    /// - Parameter contents: The contents.
    /// - Returns: A Dictionary or an Array.
    /// - Throws: An `Error` if Decoding encouters any error.
    func context(contents: String) throws -> Any?
}

extension InputSerializable {
    public func contents(at url: URL) throws -> String {
        return try String(contentsOf: url)
    }
}
