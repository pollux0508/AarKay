//
//  Task.swift
//  SharedKit
//
//  Created by Rahul Katariya on 15/04/19.
//

import Foundation
import ReactiveTask
import ReactiveSwift

public struct Task {
    /// The path to the executable that should be launched.
    public let launchPath: String

    /// Any arguments to provide to the executable.
    public let arguments: [String]

    /// The path to the working directory in which the process should be
    /// launched.
    ///
    /// If nil, the launched task will inherit the working directory of its
    /// parent.
    public let workingDirectoryPath: String?

    /// Environment variables to set for the launched process.
    ///
    /// If nil, the launched task will inherit the environment of its parent.
    public let environment: [String: String]?

    public init(
        _ launchPath: String,
        arguments: [String] = [],
        workingDirectoryPath: String? = nil,
        environment: [String: String]? = nil
    ) {
        self.launchPath = launchPath
        self.arguments = arguments
        self.workingDirectoryPath = workingDirectoryPath
        self.environment = environment
    }

    /// Launches the task and prints the output.
    ///
    /// - Returns: A result containing either success or `AarKayError`
    public func run(
        output: ((String) -> Void)? = nil
    ) -> Result<(), TaskError> {
        let task = ReactiveTask.Task(
            launchPath,
            arguments: arguments,
            workingDirectoryPath: workingDirectoryPath,
            environment: environment
        )
        let result = task.launch()
            .flatMapTaskEvents(.concat) { data in
                SignalProducer(
                    value: String(data: data, encoding: .utf8)
                )
            }
        return result.waitOnCommand(output: output)
    }
}

extension SignalProducer where Value == TaskEvent<String?>, Error == TaskError {
    /// Waits on a SignalProducer that implements the behavior of a CommandProtocol.
    internal func waitOnCommand(
        output: ((String) -> Void)? = nil
    ) -> Result<(), TaskError> {
        let result = producer
            .on(
                event: { event in
                    switch event {
                    case .value(let value):
                        switch value {
                        case .standardOutput(let data):
                            if let o = String(data: data, encoding: .utf8) {
                                output?(o)
                            }
                        case .standardError(let data):
                            if let o = String(data: data, encoding: .utf8) {
                                output?(o)
                            }
                        default: break
                        }
                    default: break
                    }
                }
            )
            .then(SignalProducer<(), TaskError>.empty)
            .wait()

        ReactiveTask.Task.waitForAllTaskTermination()
        return result
    }
}
