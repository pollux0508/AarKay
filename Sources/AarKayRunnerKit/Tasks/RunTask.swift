//
//  RunTask.swift
//  AarKayRunnerKit
//
//  Created by Rahul Katariya on 08/03/19.
//

import Foundation

public class RunTask {
    public static func run(
        at path: String,
        workingDirectoryPath: String,
        verbose: Bool = false,
        force: Bool = false,
        dryrun: Bool = false,
        exitOnError: Bool = false,
        output: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        var arguments: [String] = ["--path", workingDirectoryPath]
        if verbose { arguments.append("--verbose") }
        if force { arguments.append("--force") }
        if dryrun { arguments.append("--dryrun") }
        if exitOnError { arguments.append("--exitOnError") }

        return Tasks.execute(
            at: path,
            arguments: arguments,
            output: output
        )
    }
}
