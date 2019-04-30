//
//  InputSerializable.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 27/02/18.
//

import Foundation

/// Responsible for decoding the contents.
public protocol InputSerializable {
    /// Decodes the contents from url to Swift object.
    ///
    /// - Parameter at: The url.
    /// - Returns: A Dictionary or an Array.
    /// - Throws: An `Error` if Decoding encouters any error.
    func context(at url: URL) throws -> Any?

    /// Decodes the contents to Swift object.
    ///
    /// - Parameter at: The contents.
    /// - Returns: A Dictionary or an Array.
    /// - Throws: An `Error` if Decoding encouters any error.
    func context(from contents: String) throws -> Any?
}

extension InputSerializable {
    /// Decodes the contents to Swift object.
    public func context(from contents: String) throws -> Any? {
        return try YamlInputSerializer().context(from: contents)
    }
    
    func context(from provider: InputType) throws -> Any? {
        switch provider {
        case .url(let url):
            return try context(at: url)
        case .string(let string):
            return try context(from: string)
        }
    }
}
