import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `install` subcommand.
public struct InstallCommand: CommandProtocol {
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

    public var verb: String = "install"
    public var function: String = "Install all the plugins from `AarKayFile`."

    public init() {}

    public func run(_ options: Options) -> Result<(), AarKayError> {
        /// <aarkay Install>
        let runnerUrl = AarKayPaths.default.runnerPath(global: options.global)

        guard FileManager.default.fileExists(atPath: runnerUrl.path) else {
            return .failure(
                .missingProject(url: runnerUrl.deletingLastPathComponent())
            )
        }

        do {
            try Bootstrapper.default.updatePackageSwift(
                global: options.global,
                force: options.force
            )
        } catch {
            return .failure(error as! AarKayError)
        }
        println("Installing plugins at \(runnerUrl.relativeString). This might take a few minutes...")
        return Tasks.install(at: runnerUrl.path) { str in
            print(str)
        }
        /// </aarkay>
    }
}
