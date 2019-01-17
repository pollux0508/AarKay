import AarKayRunnerKit
import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `version` subcommand.
struct VersionCommand: CommandProtocol {
    var verb: String = "version"
    var function: String = "Display the current version of aarkay."

    func run(_ options: NoOptions<AarKayError>) -> Result<(), AarKayError> {
        /// <aarkay Version>
        println(AarKayVersion)
        return .success(())
        /// </aarkay>
    }
}
