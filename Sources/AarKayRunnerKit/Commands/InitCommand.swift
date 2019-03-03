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
        let aarkayPaths = options.global ?
            AarKayPaths.global : AarKayPaths.local
        let runnerUrl = aarkayPaths.runnerPath()
        if FileManager.default.fileExists(atPath: runnerUrl.path) && !options.force {
            return .failure(.projectAlreadyExists(url: aarkayPaths.url))
        } else {
            do {
                let bootstrapper = options.global ?
                    Bootstrapper.global : Bootstrapper.local
                try bootstrapper.bootstrap(
                    force: options.force
                )
            } catch {
                return .failure(error as! AarKayError)
            }
            let runnerUrl = aarkayPaths.runnerPath()
            println("Setting up at \(aarkayPaths.url.relativeString). This might take a few minutes...")
            return Tasks.install(at: runnerUrl.path) { str in
                print(str)
            }
        }
        /// </aarkay>
    }
}
