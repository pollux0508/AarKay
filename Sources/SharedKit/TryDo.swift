//
//  TryDo.swift
//  AarKayRunnerKit
//
//  Created by RahulKatariya on 20/01/19.
//

import Foundation

/// An abstraction over swift try catch encouraging immutable return value and
/// custom error mapping.
public class Try<Value> {
    /// The throwing block.
    private let block: () throws -> Value

    /// Initializes the Try with a throwing block.
    ///
    /// - Parameter block: The block to exectue.
    public init(block: @escaping () throws -> Value) {
        self.block = block
    }

    /// Executes the block.
    ///
    /// - Returns: The value returned by the block.
    /// - Throws: An `Error` if block encouters an error.
    public func `do`() throws -> Value {
        return try block()
    }

    /// Executes the block and maps to a given error if block fails.
    ///
    /// - Parameter mappedError: The error to throw when the block fails.
    /// - Returns: The value returned by the block.
    /// - Throws: The MappedError if block encouters any error.
    public func `do`(_ mappedError: (Error) -> Error) throws -> Value {
        do {
            return try block()
        } catch {
            throw mappedError(error)
        }
    }
}
