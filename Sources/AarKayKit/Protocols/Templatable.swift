//
//  Templatable.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 29/12/17.
//

import Foundation

/// Represents a Template.
public protocol Templatable: class {
    /// The Datafile.
    var datafile: Datafile { get set }

    /// Initializes the Templatable with the Datafile.
    ///
    /// - Parameter datafile: The Datafile.
    /// - Throws: An `Error` if decoding datafile contents encouter any error.
    init(datafile: Datafile) throws

    /// Processes the datafile and generate more datafiles from it.
    ///
    /// - Returns: An array of datafile.
    /// - Throws: An `Error` if datafiles creation encouters any error.
    func datafiles() throws -> [Datafile]

    /// Returns the `InputSerializable` to use to decode the contents of Datafile.
    static func inputSerializer() -> InputSerializable
}

extension Templatable {
    /// The datafile.
    public func datafiles() throws -> [Datafile] {
        return [datafile]
    }

    /// The YamlInputSerializer.
    public static func inputSerializer() -> InputSerializable {
        return YamlInputSerializer()
    }
}
