//
//  InitTask.swift
//  AarKayRunnerKit
//
//  Created by Rahul Katariya on 08/03/19.
//

import Foundation

public class InitTask {
    public static func run(
        at path: String,
        bootstrapper: Bootstrapper,
        force: Bool = false,
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        do {
            try bootstrapper.bootstrap(
                force: force
            )
        } catch {
            return .failure(error as! AarKayError)
        }

        return Tasks.install(
            at: path,
            standardOutput: standardOutput
        )
    }
}
