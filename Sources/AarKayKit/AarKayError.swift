import Foundation

/// A Type encpasulating all errors
///
/// - unknownError: Returned when the program gets in an unexpected state.
/// - missingFileName: Returned when there is no file name.
/// - modelDecodingFailure: Returned when the data could not be serialized to the Template.
/// - templateNotFound: Returned when the template could not be found.
/// - multipleTemplatesFound: Returned when multiple templates exist under same name.
/// - invalidTemplate: Returned when the name of template doesn't conform to AarKayTemplate.
public enum AarKayError: Error {
    case unknownError
    case missingFileName(String, String)
    case modelDecodingFailure(String)
    case templateNotFound(String)
    case multipleTemplatesFound(String)
    case invalidTemplate(String)
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
        return AarKayError.unknownError
    }
}

// MARK: - LocalizedError

extension AarKayError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingFileName(let plugin, let template):
            return "Couldn't resolve filename in \(plugin).\(template)"
        case .modelDecodingFailure(let name):
            return "Couldn't decode \(name)"
        case .templateNotFound(let name):
            return "Template with name - \(name) could not be found"
        case .multipleTemplatesFound(let name):
            return "More than one template with name - \(name) exists"
        case .invalidTemplate(let name):
            return "Template with name - \(name) is invalid"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
