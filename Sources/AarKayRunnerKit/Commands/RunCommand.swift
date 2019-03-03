import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `run` subcommand.
public struct RunCommand: CommandProtocol {
    public struct Options: OptionsProtocol {
        public let global: Bool
        public let verbose: Bool
        public let force: Bool
        public let dryrun: Bool

        public init(global: Bool, verbose: Bool, force: Bool, dryrun: Bool) {
            self.global = global
            self.verbose = verbose
            self.force = force
            self.dryrun = dryrun
        }

        public static func evaluate(
            _ mode: CommandMode
        ) -> Result<Options, CommandantError<AarKayError>> {
            return curry(self.init)
                <*> mode <| Switch(flag: "g", key: "global", usage: "Uses global version of `aarkay`.")
                <*> mode <| Switch(flag: "v", key: "verbose", usage: "Adds verbose logging.")
                <*> mode <| Switch(flag: "f", key: "force", usage: "Will not check if the directory has any uncomitted changes.")
                <*> mode <| Switch(flag: "n", key: "dryrun", usage: "Will only create files and will not write them to disk.")
        }
    }

    public var verb: String = "run"
    public var function: String = "Generate respective files from the datafiles inside AarKayData."

    public init() {}

    public func run(_ options: Options) -> Result<(), AarKayError> {
        /// <aarkay Run>
        let aarkayPaths = options.global ?
            AarKayPaths.global : AarKayPaths.local
        var runnerUrl = aarkayPaths.runnerPath()
        var cliUrl: URL = aarkayPaths.cliPath()

        if !FileManager.default.fileExists(atPath: runnerUrl.path) || options.global {
            runnerUrl = AarKayPaths.global.runnerPath()
            cliUrl = AarKayPaths.global.cliPath()
        }

        guard FileManager.default.fileExists(atPath: runnerUrl.path),
            FileManager.default.fileExists(atPath: cliUrl.path) else {
            return .failure(
                AarKayError.missingProject(url: runnerUrl.deletingLastPathComponent())
            )
        }

        return run(
            at: cliUrl.path,
            verbose: options.verbose,
            force: options.force,
            dryrun: options.dryrun
        ) { str in
            print(str)
        }
        /// </aarkay>
    }
}

// MARK: - AarKayEnd

extension RunCommand {
    public func run(
        at path: String,
        verbose: Bool = false,
        force: Bool = false,
        dryrun: Bool = false,
        standardOutput: ((String) -> Void)? = nil
    ) -> Result<(), AarKayError> {
        var arguments: [String] = []
        if verbose { arguments.append("--verbose") }
        if force { arguments.append("--force") }
        if dryrun { arguments.append("--dryrun") }

        return Tasks.execute(
            at: path,
            arguments: arguments,
            standardOutput: standardOutput
        )
    }
}
