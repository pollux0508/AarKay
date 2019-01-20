//
//  AarKayLogger.swift
//  AarKay
//
//  Created by RahulKatariya on 22/12/18.
//

import Foundation
import PrettyColors
import SwiftyTextTable

/// A type that encapsulates all logging events of AarKay.
class AarKayLogger {
    /// Logs for location of project and its datafiles when the project is bootstrapped.
    ///
    /// - Parameters:
    ///   - url: The url of the `Project`.
    ///   - datafilesUrl: The url of the `Datafiles`.
    static func logTable(url: URL, datafilesUrl: URL) {
        let column = TextTableColumn(header: "🚀 Launch---i--n--g--> " + url.path)
        var table = TextTable(columns: [column])
        table.addRow(values: ["🙏🏻 AarKayData-------> " + datafilesUrl.path])
        print(table.render().magenta)
    }

    /// Logs for missing datafiles.
    static func logNoDatafiles() {
        print("🚫 No datafiles found. To get started, visit https://github.com/RahulKatariya/AarKay".red)
    }

    /// Logs for dirty directory.
    static func logDirtyRepo() {
        print(
            "🚫 Please discard or stash all your changes to git or try it inside an empty folder".red
        )
    }

    /// Logs for error.
    ///
    /// - Parameter error: The `Error` object.
    static func logError(_ error: Error) {
        print("   <!> \(error.localizedDescription)".red)
    }

    /// Logs for error message.
    ///
    /// - Parameter message: The error message.
    static func logErrorMessage(_ message: String) {
        print("   <!> \(message)".red)
    }

    /// Logs for `Datafile` location.
    ///
    /// - Parameter url: The url of the datafile.
    static func logDatafile(at url: URL) {
        print("<^> \(url.lastPathComponent)".blue)
    }

    /// Logs for a file being created.
    ///
    /// - Parameter url: The url of the created file.
    static func logFileAdded(at url: URL) {
        print("   <+> \(url.relativeString)".green)
    }

    /// Logs for a file being modified.
    ///
    /// - Parameter url: The url of the modified file.
    static func logFileModified(at url: URL) {
        print("   <*> \(url.relativeString)".yellow)
    }

    /// Logs for a file not changed.
    ///
    /// - Parameter url: The url of the unchanged file.
    static func logFileUnchanged(at url: URL) {
        print("   <-> \(url.relativeString)")
    }

    /// Logs for a file skipped.
    ///
    /// - Parameter url: The url of the skipped file.
    static func logFileSkipped(at url: URL) {
        print("   <X> \(url.relativeString)".cyan)
    }

    /// Logs for a file errored.
    ///
    /// - Parameters:
    ///   - url: The url of the skipped file.
    ///   - error: The `Error` object.
    ///   - verbose: The verbose logging flag.
    static func logFileErrored(
        at url: URL,
        error: Error,
        verbose: Bool
    ) {
        print("   <!> \(url.absoluteString)".red)
        if verbose { logError(error) }
    }
}
