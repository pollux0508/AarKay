//
//  RunTask.swift
//  AarKayRunnerKit
//
//  Created by Rahul Katariya on 08/03/19.
//

import Foundation
import Result

public class RunTask {
    public static func run(
        at path: String,
        verbose: Bool = false,
        force: Bool = false,
        dryrun: Bool = false,
        exitOnError: Bool = false,
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        var arguments: [String] = []
        if verbose { arguments.append("--verbose") }
        if force { arguments.append("--force") }
        if dryrun { arguments.append("--dryrun") }
        if exitOnError { arguments.append("--exitOnError") }

        return Tasks.execute(
            at: path,
            arguments: arguments,
            standardOutput: standardOutput
        )
    }
}
