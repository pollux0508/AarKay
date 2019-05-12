//
//  Task.swift
//  SharedKit
//
//  Created by Rahul Katariya on 15/04/19.
//

import Foundation

public struct TaskError: Error {
    let terminationStatus: Int32
}

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

        var outputData = Data()
        var errorData = Data()

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.standardOutput = outputPipe
        process.standardError = errorPipe

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let string = String(data: data, encoding: .utf8), data.count > 0 {
                outputData.append(data)
                output?(string)
            }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let string = String(data: data, encoding: .utf8), data.count > 0 {
                errorData.append(data)
                output?(string)
            }
        }
        #endif

        process.launch()

        #if os(Linux)
        outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let string = String(data: outputData, encoding: .utf8), outputData.count > 0 {
            output?(string)
        }
        errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let string = String(data: errorData, encoding: .utf8), errorData.count > 0 {
            output?(string)
        }
        #endif

        process.waitUntilExit()

        outputPipe.fileHandleForReading.closeFile()
        errorPipe.fileHandleForReading.closeFile()

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        #endif

        var result: Result<(), Error>!
        if process.terminationStatus != 0 {
            result = .failure(TaskError(terminationStatus: process.terminationStatus))
        } else {
            result = .success(())
        }
        return result
    }
}
