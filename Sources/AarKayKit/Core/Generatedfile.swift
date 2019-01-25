//
//  Generatedfile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 24/08/18.
//

import Foundation
import SharedKit

/// Represents a Generatedfile.
public struct Generatedfile {
    /// The respective Datafile.
    public let datafile: Datafile

    /// The extension of the file.
    public let ext: String?

    /// The contents of the file.
    public let contents: String

    /// The filename with the extension.
    public var nameWithExt: String {
        if let ext = self.ext {
            return datafile.fileName + "." + ext
        } else {
            return datafile.fileName
        }
    }

    /// Initializes a Generatedfile.
    ///
    /// - Parameters:
    ///   - datafile: The respective Datafile.
    ///   - ext: The extension of the file.
    ///   - contents: The contents of the file.
    init(
        datafile: Datafile,
        ext: String?,
        contents: String
    ) {
        self.datafile = datafile
        self.ext = ext.nilIfEmpty()
        self.contents = contents
    }

    /// Merges the existing string with the string generated by the template using the marks.
    ///
    /// - Parameter string: The contents of existing file.
    /// - Returns: The merged file contents.
    /// - Throws: Errors while merging using the regex.
    public func merge(_ string: String) throws -> String {
        var template = contents
        template = try string.merge(
            template: template,
            regex: "\\n?(.*?)<aarkay (.*)>([\\s\\S]*?)\\n(.*?)<\\/aarkay>(.*?)\\n?"
        )
        template = string.append(
            template: template,
            regex: "\\n?(.*?)AarKayEnd"
        )
        return template
    }
}
