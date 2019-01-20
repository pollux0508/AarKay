import Foundation

/// A type encapsulating all errors related to `AarKayKit`.
///
/// - unknownError: Returned when the program reaches an unexpected state.
/// - missingFileName: Returned when there is no file name.
/// - modelDecodingFailure: Returned when the data could not be serialized to the Template.
/// - templateNotFound: Returned when the template could not be found.
/// - multipleTemplatesFound: Returned when multiple templates exist under same name.
/// - invalidTemplate: Returned when the name of template doesn't conform to AarKayTemplate.
public enum AarKayError: Error {
    case unknownError(error: Error?)
    case invalidContents(InvalidContentsReason)
    case invalidTemplate(InvalidTemplateReason)

    /// The underlying reason the invalid contents error occurred.
    ///
    /// - serializationFailed: Returned when the data is in invalid format.
    /// - objectExpected: Returned when object is expected to decode single.
    /// - arrayExpected: Returned when array is expected to decode collection.
    /// - invalidModel: Returned when the data doesn't match the requirements of template.
    /// - missingFileName: Returned when there is no filename for generatedfile.
    public enum InvalidContentsReason {
        case serializationFailed
        case objectExpected
        case arrayExpected
        case invalidModel
        case missingFileName
    }

    /// The underlying reason the invalid templates error occurred.
    ///
    /// - mutipleFound: Returned when there are more than one template with the same name.
    /// - notFound: Returned when there is no template with that name.
    /// - invalidName: Returned when the template name is invalid.
    public enum InvalidTemplateReason {
        case mutipleFound
        case notFound
        case invalidName
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
        case .invalidContents(let reason):
            return reason.localizedDescription
        case .invalidTemplate(let reason):
            return reason.localizedDescription
        }
    }
}

extension AarKayError.InvalidContentsReason: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serializationFailed:
            return "Invalid contents."
        case .arrayExpected:
            return "Expected an array."
        case .objectExpected:
            return "Expected an object."
        case .invalidModel:
            return "The data doesn't conform to the Template."
        case .missingFileName:
            return "Couldn't resolve filename."
        }
    }
}

extension AarKayError.InvalidTemplateReason: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .mutipleFound:
            return "Mutliple templates found"
        case .notFound:
            return "Could not find the template"
        case .invalidName:
            return "The template of the template is wrong"
        }
    }
}
