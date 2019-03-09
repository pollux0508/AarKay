//
//  AarKayOptions.swift
//  AarKay
//
//  Created by RahulKatariya on 01/01/19.
//

import Foundation

/// A type that encapsulates the options for `AarKay`.
public struct AarKayOptions {
    /// The force flag.
    let force: Bool

    /// The verbose flag.
    let verbose: Bool

    /// The dryrun flag.
    let dryrun: Bool

    /// The exitOnError flag.
    let exitOnError: Bool

    /// Initializes `AarKayOptions`
    ///
    /// - Parameters:
    ///   - force: The force flag when set to false will not overwrite your files with the generated files if the directory is dirty. It ensures that the directory is empty or it's a clean git repository. `false` by default.
    ///   - verbose: The flag to print verbose logging to console. `false` by default.
    ///   - dryrun: The flag when set to true will only print and not write files to disk. `false` by default.
    ///   - exitOnError: The flag when set to true will exit the process if an error is encoutered.
    public init(
        force: Bool = false,
        verbose: Bool = false,
        dryrun: Bool = false,
        exitOnError: Bool = false
    ) {
        self.force = force
        self.verbose = verbose
        self.dryrun = dryrun
        self.exitOnError = exitOnError
    }
}
