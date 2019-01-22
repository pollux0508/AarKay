//
//  StringTransformable.swift
//  AarKayPlugin
//
//  Created by RahulKatariya on 13/08/18.
//

import Foundation

/// A type that can be converted from a string.
public protocol StringTransformable {
    static func transform(value: String) -> Self?
}

extension String: StringTransformable {
    /// Conforms to StringTransformable.
    ///
    /// - Parameter value: The value string.
    /// - Returns: The value itself.
    public static func transform(value: String) -> String? {
        return value
    }
}

extension Bool: StringTransformable {
    /// Transforms the value to a swift Bool.
    ///
    /// - Parameter value: The bool value in string format.
    /// - Returns: nil if failed otherwise the casted Bool.
    public static func transform(value: String) -> Bool? {
        switch value {
        case "true", "yes", "1": return true
        case "false", "no", "0": return false
        default: return nil
        }
    }
}

extension Int: StringTransformable {
    /// Transforms the value to a swift Int.
    ///
    /// - Parameter value: The int value in string format.
    /// - Returns: nil if failed otherwise the casted Int.
    public static func transform(value: String) -> Int? {
        return Int(value)
    }
}

extension Int16: StringTransformable {
    /// Transforms the value to a swift Int16.
    ///
    /// - Parameter value: The int16 value in string format.
    /// - Returns: nil if failed otherwise the casted Int16.
    public static func transform(value: String) -> Int16? {
        return Int16(value)
    }
}

extension Int32: StringTransformable {
    /// Transforms the value to a swift Int32.
    ///
    /// - Parameter value: The int32 value in string format.
    /// - Returns: nil if failed otherwise the casted Int32.
    public static func transform(value: String) -> Int32? {
        return Int32(value)
    }
}

extension Int64: StringTransformable {
    /// Transforms the value to a swift Int64.
    ///
    /// - Parameter value: The int64 value in string format.
    /// - Returns: nil if failed otherwise the casted Int64.
    public static func transform(value: String) -> Int64? {
        return Int64(value)
    }
}

extension Float: StringTransformable {
    /// Transforms the value to a swift Float.
    ///
    /// - Parameter value: The float value in string format.
    /// - Returns: nil if failed otherwise the casted Float.
    public static func transform(value: String) -> Float? {
        return Float(value)
    }
}

extension Double: StringTransformable {
    /// Transforms the value to a swift Double.
    ///
    /// - Parameter value: The double value in string format.
    /// - Returns: nil if failed otherwise the casted Double.
    public static func transform(value: String) -> Double? {
        return Double(value)
    }
}
