import Foundation
import ReactiveTask

/// A type encapsulating all errors related to `AarKay` commands.
///
/// - unknownError: Returned when the program reaches an unexpected state.
/// - projectAlreadyExists: Returned when init is tried on the project that already exists.
/// - missingProject: Returned when the project doesn't exist.
/// - aarkayFileParsingFailed: Returned when the AarKayFile parsing fails.
/// - taskError: Returned when the task fails.
public enum AarKayError: Error {
    case unknownError(error: Error?)
    case projectAlreadyExists(String)
    case missingProject(String)
    case aarkayFileParsingFailed(reason: AarKayFileParsingReason)
    case taskError(TaskError)

    /// The underlying reason the aarkayfile parsing error occurred.
    ///
    /// - missingFile: Returned if AarKayFile doesn't exist at the URL.
    /// - missingAarKayDependency: Returned if the file doesn't have AarKay as its dependency.
    /// - invalidVersion: Returned if the version is in invalid format.
    /// - invalidDependency: Returned if the dependency is in invalid format.
    public enum AarKayFileParsingReason {
        case missingFile(URL)
        case missingAarKayDependency(URL)
        case invalidVersion(String)
        case invalidDependency(String)
    }
}

extension AarKayError {
    public static func internalError(
        _ message: String,
        with error: Error? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AarKayError {
        /// <aarkay internalError>
        assertionFailure("\(file):\(line) - \(message). \(error.debugDescription)")
        /// </aarkay>
        return AarKayError.unknownError(error: error)
    }
}

// MARK: - LocalizedError

extension AarKayError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownError(let error):
            var desc = "An unknown error occurred."
            if let err = error {
                desc = desc + "- " + err.localizedDescription
            }
            return desc
        case .projectAlreadyExists(let path):
            return "Project already exists at \(path). Use `--force` to start over."
        case .missingProject(let path):
            return "AarKay is not yet setup at \(path). Use `aarkay init [--global]` to setup."
        case .aarkayFileParsingFailed(let reason):
            return reason.localizedDescription
        case .taskError(let error):
            return error.description
        }
    }
}

extension AarKayError.AarKayFileParsingReason {
    public var localizedDescription: String {
        switch self {
        case .missingFile(let url):
            return "AarKayFile was missing at url - \(url.path)."
        case .missingAarKayDependency(let url):
            return "Could not find the dependency - http://github.com/RahulKatariya/AarKay, ~> \(AarKayVersion) at \(url)."
        case .invalidVersion(let version):
            return "Version - \(version) could not be validated."
        case .invalidDependency(let dependency):
            return "Dependency - \(dependency) could not be validated."
        }
    }
}
