//
//  OptionalExtensions.swift
//  AarKayKit
//
//  Created by RahulKatariya on 13/01/19.
//

import Foundation

extension Optional where Wrapped == String {
    public func nilIfEmpty(file: StaticString = #file, line: UInt = #line) -> Wrapped? {
        guard let item = self else {
            return nil
        }
        guard !item.trimmingCharacters(in: .whitespaces).isEmpty else {
            assertionFailure("String should not be empty", file: file, line: line)
            return nil
        }
        return item
    }
}

extension String {
    public func failIfEmpty(file: StaticString = #file, line: UInt = #line) -> String {
        if trimmingCharacters(in: .whitespaces).isEmpty {
            assertionFailure("String should not be empty", file: file, line: line)
        }
        return self
    }
}
