import AarKayRunnerKit
import Commandant
import Curry
import Foundation

/// Type that encapsulates the configuration and evaluation of the `run` subcommand.
public struct RunCommand: CommandProtocol {
    public typealias ClientError = AarKayError

    public struct Options: OptionsProtocol {
        public let global: Bool
        public let verbose: Bool
        public let force: Bool
        public let dryrun: Bool
        public let exitOnError: Bool

        public init(global: Bool, verbose: Bool, force: Bool, dryrun: Bool, exitOnError: Bool) {
            self.global = global
            self.verbose = verbose
            self.force = force
            self.dryrun = dryrun
            self.exitOnError = exitOnError
        }

        public static func evaluate(
            _ mode: CommandMode
        ) -> Result<Options, CommandantError<AarKayError>> {
            return curry(self.init)
                <*> mode <| Switch(flag: "g", key: "global", usage: "Uses global version of `aarkay`.")
                <*> mode <| Switch(flag: "v", key: "verbose", usage: "Adds verbose logging.")
                <*> mode <| Switch(flag: "f", key: "force", usage: "Will not check if the directory has any uncomitted changes.")
                <*> mode <| Switch(flag: "n", key: "dryrun", usage: "Will only create files and will not write them to disk.")
                <*> mode <| Switch(flag: "e", key: "exitOnError", usage: "Exits the process if an error is encoutered.")
        }
    }

    public var verb: String = "run"
    public var function: String = "Generate respective files from the datafiles inside AarKayData."

    public init() {}

    public func run(_ options: Options) -> Result<(), AarKayError> {
        /// <aarkay Run>
        let aarkayPaths = options.global ?
            AarKayPaths.global : AarKayPaths.local
        let runnerUrl = aarkayPaths.runnerPath()
        let cliUrl = aarkayPaths.cliPath()

        guard FileManager.default.fileExists(atPath: runnerUrl.path),
            FileManager.default.fileExists(atPath: cliUrl.path) else {
            return .failure(
                AarKayError.missingProject(
                    url: runnerUrl
                        .deletingLastPathComponent()
                        .deletingLastPathComponent()
                )
            )
        }

        return RunTask.run(
            at: cliUrl.path,
            workingDirectoryPath: FileManager.default.currentDirectoryPath,
            verbose: options.verbose,
            force: options.force,
            dryrun: options.dryrun,
            exitOnError: options.exitOnError
        ) { str in
            print(str)
        }
        /// </aarkay>
    }
}
