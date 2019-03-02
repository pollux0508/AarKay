import Commandant
import Curry
import Foundation
import Result

/// Type that encapsulates the configuration and evaluation of the `version` subcommand.
public struct VersionCommand: CommandProtocol {
    public var verb: String = "version"
    public var function: String = "Display the current version of aarkay."

    public init() {}

    public func run(_ options: NoOptions<AarKayError>) -> Result<(), AarKayError> {
        /// <aarkay Version>
        println(AarKayVersion)
        return .success(())
        /// </aarkay>
    }
}
