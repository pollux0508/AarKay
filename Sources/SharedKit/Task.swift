//
//  Task.swift
//  SharedKit
//
//  Created by Rahul Katariya on 15/04/19.
//

import Foundation

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
    ) -> Result<(), Error> {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        if let env = environment { process.environment = env }
        if let wdp = workingDirectoryPath { process.currentDirectoryPath = wdp }
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            if let string = String(data: fileHandle.availableData, encoding: .utf8) {
                output?(string)
            }
        }
        let errorPipe = Pipe()
        process.standardError = errorPipe
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            if let string = String(data: fileHandle.availableData, encoding: .utf8) {
                output?(string)
            }
        }
        process.launch()
        process.waitUntilExit()
        return .success(())
    }
}
