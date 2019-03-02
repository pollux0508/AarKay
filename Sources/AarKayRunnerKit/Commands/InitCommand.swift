import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `init` subcommand.
public struct InitCommand: CommandProtocol {
    public struct Options: OptionsProtocol {
        public let global: Bool
        public let force: Bool

        public init(global: Bool, force: Bool) {
            self.global = global
            self.force = force
        }

        public static func evaluate(
            _ mode: CommandMode
        ) -> Result<Options, CommandantError<AarKayError>> {
            return curry(self.init)
                <*> mode <| Switch(flag: "g", key: "global", usage: "Uses global version of `aarkay`.")
                <*> mode <| Switch(flag: "f", key: "force", usage: "Resets aarkay and starts over.")
        }
    }

    public var verb: String = "init"
    public var function: String = "Initialize AarKay and install all the plugins from `AarKayFile`."

    public init() {}

    public func run(_ options: Options) -> Result<(), AarKayError> {
        /// <aarkay Init>
        let url = AarKayPaths.default.directoryPath(global: options.global)
        let runnerUrl = AarKayPaths.default.runnerPath(global: options.global)
        if FileManager.default.fileExists(atPath: runnerUrl.path) && !options.force {
            return .failure(.projectAlreadyExists(url: url))
        } else {
            do {
                try Bootstrapper.default.bootstrap(
                    global: options.global,
                    force: options.force
                )
            } catch {
                return .failure(error as! AarKayError)
            }
            let runnerUrl = AarKayPaths.default.runnerPath(global: options.global)
            println("Setting up at \(url.relativeString). This might take a few minutes...")
            return Tasks.install(at: runnerUrl.path) { str in
                print(str)
            }
        }
        /// </aarkay>
    }
}
