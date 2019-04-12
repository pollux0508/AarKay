//
//  BuildTask.swift
//  AarKayRunner
//
//  Created by RahulKatariya on 01/01/19.
//

import Foundation
import ReactiveSwift
import ReactiveTask

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
        return Task(path, arguments: arguments).run(standardOutput: standardOutput)
    }
}

extension Task {
    /// Launches the task and prints the output.
    ///
    /// - Returns: A result containing either success or `AarKayError`
    internal func run(
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        let result = launch()
            .flatMapTaskEvents(.concat) { data in
                SignalProducer(
                    value: String(data: data, encoding: .utf8)
                )
            }
        return result.waitOnCommand(standardOutput: standardOutput)
    }
}

extension SignalProducer where Value == TaskEvent<String?>, Error == TaskError {
    /// Waits on a SignalProducer that implements the behavior of a CommandProtocol.
    internal func waitOnCommand(
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        let result = producer
            .on(
                event: { event in
                    switch event {
                    case .value(let value):
                        switch value {
                        case .standardOutput(let data):
                            if let o = String(data: data, encoding: .utf8) {
                                standardOutput?(o)
                            }
                        default: break
                        }
                    default: break
                    }
                }
            )
            .mapError(AarKayError.taskError)
            .then(SignalProducer<(), AarKayError>.empty)
            .wait()

        Task.waitForAllTaskTermination()
        return result
    }
}
