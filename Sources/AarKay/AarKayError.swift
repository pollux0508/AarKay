import Foundation

/// A type encapsulating all errors related to `AarKay`.
///
/// - unknownError: Returned when the program reaches an unexpected state.
/// - globalContextReadFailed: Returned when unable to read the global context.
public enum AarKayError: Error {
    case unknownError(error: Error?)
    case globalContextReadFailed(url: URL)
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
        case .globalContextReadFailed(let url):
            return "Failed to serialize the contents of \(url) to an object."
        }
    }
}
