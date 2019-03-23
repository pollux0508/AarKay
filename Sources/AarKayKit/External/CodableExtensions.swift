//
//  CodableExtensions.swift
//  AarKayKit
//
//  Created by RahulKatariya on 10/02/19.
//

import Foundation
import SharedKit

struct ArrayEncodable<T: Encodable>: Encodable {
    let items: T
}

public class JSONCoder {
    /// Decodes and Encodes the model and sets the context.
    ///
    /// - Parameter type: The type of `Codable`.
    /// - Returns: The decoded model.
    /// - Throws: An `Error` if JSON Decoding or Encoding encouters any error.
    public static func dencode<T: Codable>(type: T.Type, context: Any) throws -> [String: Any] {
        let model = try decode(type: type, context: context)
        guard let object = try encode(model) as? [String: Any] else {
            throw AarKayKitError.internalError(
                "Failed to decode object from encoded data"
            )
        }
        return object
    }

    /// Decodes the dictionary to the `Decodable` type.
    ///
    /// - Parameter type: The type of `Decodable`.
    /// - Returns: The decoded model.
    /// - Throws: An `Error` if JSON Decoding encouters any error.
    public static func decode<T: Decodable>(type: T.Type, context: Any) throws -> T {
        let decodedData = try JSONSerialization.data(withJSONObject: context)
        return try JSONDecoder().decode(type, from: decodedData) as T
    }

    /// Encodes the model to an object.
    ///
    /// - Parameters: model: The model conforming to `Encodable`.
    /// - Returns: The encoded model.
    /// - Throws: An `Error` if JSON encoding encounters any error.
    public static func encode<T: Encodable>(_ model: T) throws -> Any {
        let encodedData = try JSONEncoder().encode(model)
        return try JSONSerialization.jsonObject(
            with: encodedData,
            options: .allowFragments
        )
    }
}
