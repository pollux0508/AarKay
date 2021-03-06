//
//  DictionaryExtension.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 28/02/18.
//

import Foundation

/// Merges two optional dictionaries.
///
/// - Parameters:
///   - lhs: The first dictionary.
///   - rhs: The second dictionary.
/// - Returns: The merged dictionary.
public func + <T, U>(lhs: [T: U]?, rhs: [T: U]?) -> [T: U]? {
    guard let lhs = lhs else { return rhs }
    guard let rhs = rhs else { return lhs }
    return lhs + rhs
}

/// Merges two dictionaries.
///
/// - Parameters:
///   - lhs: The first dictionary.
///   - rhs: The second dictionary.
/// - Returns: The merged dictionary.
public func + <T, U>(lhs: [T: U], rhs: [T: U]) -> [T: U] {
    var merged = lhs
    for (key, val) in rhs {
        merged[key] = val
    }
    return merged
}
