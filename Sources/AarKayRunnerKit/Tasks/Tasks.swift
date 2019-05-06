//
//  BuildTask.swift
//  AarKayRunner
//
//  Created by RahulKatariya on 01/01/19.
//

import Foundation
import SharedKit

/// Type that encapsulates all task events in AarKay.
public class Tasks {
    /// Builds the `AarKayRunner` swift package.
    ///
    /// - Parameter path: The working directory path.
    /// - Returns: A result containing either success or `AarKayError`.
    public static func build(
        at path: String,
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        let buildArguments = [
            "build", "-c", "debug",
            "-Xswiftc", "-target", "-Xswiftc", "x86_64-apple-macosx10.12",
        ]
        let task = Task(
            "/usr/bin/swift",
            arguments: buildArguments,
            workingDirectoryPath: path
        )
        return task.run(standardOutput: standardOutput)
            .mapError { AarKayError.taskError($0.description) }
    }

    /// Updates the dependencies of `AarKayRunner` swift package.
    ///
    /// - Parameter path: The working directory path.
    /// - Returns: A result containing either success or `AarKayError`.
    public static func update(
        at path: String,
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        let buildArguments = [
            "package",
            "update",
        ]
        let task = Task(
            "/usr/bin/swift",
            arguments: buildArguments,
            workingDirectoryPath: path
        )
        let result = task.run(standardOutput: standardOutput)
            .mapError { AarKayError.taskError($0.description) }
        guard result.error == nil else { return result }
        return build(at: path)
    }

    /// Resolves the `AarKayRunner` swift packages with respect to Package.resolved.
    ///
    /// - Parameter path: The working directory path.
    /// - Returns: A result containing either success or `AarKayError`.
    public static func install(
        at path: String,
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        let buildArguments = [
            "package",
            "resolve",
        ]
        let task = Task(
            "/usr/bin/swift",
            arguments: buildArguments,
            workingDirectoryPath: path
        )
        let result = task.run(standardOutput: standardOutput)
            .mapError { AarKayError.taskError($0.description) }
        guard result.error == nil else { return result }
        return build(at: path)
    }

    /// Executes the path as the shell command.
    ///
    /// - Parameter
    ///   - path: The path to execute as shell command.
    ///   - arguments: The list of arguments.
    /// - Returns: A result containing either success or `AarKayError`.
    public static func execute(
        at path: String,
        arguments: [String] = [],
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        return Task(path, arguments: arguments)
            .run(standardOutput: standardOutput)
            .mapError { AarKayError.taskError($0.description) }
    }
}
