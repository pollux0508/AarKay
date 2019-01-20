//
//  Try.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 20/01/19.
//

import Foundation

public struct Try<Value> {
    private let block: () throws -> Value

    public init(block: @escaping () throws -> Value) {
        self.block = block
    }

    public func catchMapError(_ mappedError: (Error) -> Error) throws -> Value {
        do {
            return try block()
        } catch {
            throw mappedError(error)
        }
    }
}
