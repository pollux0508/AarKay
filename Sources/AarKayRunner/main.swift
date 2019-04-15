import AarKayRunnerKit
import Commandant
import Foundation

/// Command registry containing all commands supported by `AarKay`.
let registry = CommandRegistry<AarKayError>()
registry.register(InitCommand())
registry.register(InstallCommand())
registry.register(RunCommand())
registry.register(UpdateCommand())
registry.register(VersionCommand())
registry.register(HelpCommand(registry: registry))

/// Setting the default command to `run`.
registry.main(defaultVerb: "run") { error in
    if let description = error.errorDescription {
        fputs(description + "\n", stderr)
    } else {
        fputs("", stderr)
    }
}
