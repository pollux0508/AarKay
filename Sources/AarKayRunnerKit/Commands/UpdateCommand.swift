import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `update` subcommand.
public struct UpdateCommand: CommandProtocol {
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
                <*> mode <| Switch(flag: "f", key: "force", usage: "Resets the `Package.resolved`.")
        }
    }

    public var verb: String = "update"
    public var function: String = "Update all the plugins from `AarKayFile`."

    public init() {}

    public func run(_ options: Options) -> Result<(), AarKayError> {
        /// <aarkay Update>
        let aarkayPaths = options.global ?
            AarKayPaths.global : AarKayPaths.local
        let runnerUrl = aarkayPaths.runnerPath()

        guard FileManager.default.fileExists(atPath: runnerUrl.path) else {
            return .failure(
                .missingProject(url: runnerUrl.deletingLastPathComponent())
            )
        }

        do {
            let bootstrapper = options.global ?
                Bootstrapper.global : Bootstrapper.local
            try bootstrapper.updatePackageSwift(
                force: options.force
            )
        } catch {
            return .failure(error as! AarKayError)
        }
        println("Updating Plugins at \(runnerUrl.relativeString). This might take a few minutes...")
        return Tasks.update(at: runnerUrl.path) { str in
            print(str)
        }
        /// </aarkay>
    }
}
