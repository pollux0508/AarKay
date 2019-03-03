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
        let aarkayPaths = options.global ?
            AarKayPaths.global : AarKayPaths.local
        let runnerUrl = aarkayPaths.runnerPath()

        guard FileManager.default.fileExists(atPath: runnerUrl.path) else {
            return .failure(
                .missingProject(url: runnerUrl.deletingLastPathComponent())
            )
        }
        println("Installing plugins at \(runnerUrl.relativeString). This might take a few minutes...")

        let bootstrapper = options.global ?
            Bootstrapper.global : Bootstrapper.local
        return run(
            at: runnerUrl.path,
            bootstrapper: bootstrapper,
            force: options.force
        ) { str in
            print(str)
        }
        /// </aarkay>
    }
}

/// MARK: - AarKayEnd
extension InstallCommand {
    public func run(
        at path: String,
        bootstrapper: Bootstrapper,
        force: Bool = false,
        standardOutput: ((String) -> ())? = nil
    ) -> Result<(), AarKayError> {
        do {
            try bootstrapper.updatePackageSwift(
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
