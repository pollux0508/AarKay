//
//  TypeValueTransformer.swift
//  AarKayPlugin
//
//  Created by RahulKatariya on 13/08/18.
//

import Foundation

/// Responsible for transforming string to its respective type.
public class TypeValueTransformer {
    /// Collection of swift type transformers
    private static var transformers: [String: StringTransformable.Type] = [
        "String": String.self,
        "Bool": Bool.self,
        "Int": Int.self,
        "Int16": Int16.self,
        "Int32": Int32.self,
        "Int64": Int64.self,
        "Float": Float.self,
        "Double": Double.self,
    ]

    /// Registers a String transformerable
    ///
    /// - Parameter transformer: The string transformable
    public static func register(transformer: StringTransformable.Type) {
        transformers[String(describing: transformer)] = transformer
    }

    let value: Any?

    /// Initializes a typed value by transforming the given value with respect to type.
    ///
    /// - Parameters:
    ///   - type: The swift type.
    ///   - value: The value of type in string format.
    /// - Returns: nil if transformer for the type is not registered.
    init?(type: String, value: String) {
        if let transformer = TypeValueTransformer.transformers[type] {
            self.value = transformer.transform(value: value)
        } else {
            return nil
        }
    }
}
