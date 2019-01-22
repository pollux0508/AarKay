//
//  NameTypeValue.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 02/01/18.
//

import Foundation

/// A type encapsulating all errors related to `NameTypeValue`.
///
/// - invalidTransformation: Returned when value could not be casted to given type.
public enum NameTypeValueError: Error {
    case invalidTransformation(type: String, value: String)
}

extension NameTypeValueError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTransformation(let type, let value):
            return "Failed to cast value - (\(value)) to type - (\(type)) "
        }
    }
}

/// Represents a collection of swift properties.
public struct NameTypeValue {
    let names: [String]
    let types: [String]
    let values: [String]

    /// Initializes NameTypeValue object with properties.
    ///
    /// - Parameters:
    ///   - names: The names of the variables
    ///   - types: The types of the variables.
    ///   - value: The value of the variable joined by '|'.
    public init(names: [String], types: [String], value: String) {
        self.names = names
        self.types = types
        self.values = value.components(separatedBy: "|")
    }

    /// Converts the object to a dictionary of names and values.
    ///
    /// - Returns: Returns the dictionary.
    /// - Throws: NameTypeValueError.
    public func toDictionary() throws -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for (name, type, value) in zip(names, types, values) {
            let strippedType = isOptional(type: type) ? String(type.dropLast()) : type
            if let value = TypeValueTransformer(type: strippedType, value: value)?.value {
                dictionary[name] = value
            } else if !isOptional(type: type) {
                throw NameTypeValueError
                    .invalidTransformation(type: type, value: value)
            }
        }
        return dictionary
    }

    /// Whether the type is optional.
    func isOptional(type: String) -> Bool {
        guard let lastChar = type.last else { return false }
        return (lastChar == "?" || lastChar == "!") ? true : false
    }
}
