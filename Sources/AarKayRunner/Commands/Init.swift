import AarKayRunnerKit
import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `init` subcommand.
struct InitCommand: CommandProtocol {
    struct Options: OptionsProtocol {
        let global: Bool
        let force: Bool

        public static func evaluate(
            _ mode: CommandMode
        ) -> Result<Options, CommandantError<AarKayError>> {
            return curry(self.init)
                <*> mode <| Switch(flag: "g", key: "global", usage: "Uses global version of `aarkay`.")
                <*> mode <| Switch(flag: "f", key: "force", usage: "Resets aarkay and starts over.")
        }
    }

    var verb: String = "init"
    var function: String = "Initialize AarKay and install all the plugins from `AarKayFile`."

    func run(_ options: Options) -> Result<(), AarKayError> {
        /// <aarkay Init>
        let url = AarKayPaths.default.directoryPath(global: options.global)
        let runnerUrl = AarKayPaths.default.runnerPath(global: options.global)
        if FileManager.default.fileExists(atPath: runnerUrl.path) && !options.force {
            return .failure(.projectAlreadyExists(url.path))
        } else {
            do {
                try Bootstrapper.default.bootstrap(global: options.global, force: options.force)
            } catch {
                return .failure(.bootstrap(error))
            }
            let runnerUrl = AarKayPaths.default.runnerPath(global: options.global)
            println("Setting up at \(url.path). This might take a few minutes...")
            return Tasks.install(at: runnerUrl.path)
        }
        /// </aarkay>
    }
}
