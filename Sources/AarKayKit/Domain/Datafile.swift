//
//  Datafile.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 31/12/17.
//

import Foundation

public enum Template {
    case name(String)
    case nameStringExt(String, String, String)

    public func name() -> String {
        switch self {
        case .name(let name): return name
        case .nameStringExt(let name, _, _): return name
        }
    }
}

public struct Datafile {
    public private(set) var fileName: String
    public private(set) var directory: String?
    public private(set) var context: [String: Any]
    public private(set) var override: Bool
    public private(set) var skip: Bool
    public private(set) var template: Template
    public private(set) var globalContext: [String: Any]?

    public init(
        fileName: String,
        directory: String?,
        context: [String: Any],
        override: Bool,
        skip: Bool,
        template: Template,
        globalContext: [String: Any]?
    ) {
        self.directory = directory.nilIfEmpty()
        self.fileName = fileName.failIfEmpty()
        self.context = context
        self.override = override
        self.skip = skip
        self.template = template
        self.globalContext = globalContext
    }

    public mutating func dencode<T: Codable>(type: T.Type) throws -> T {
        let model = try decode(type: type)
        try setContext(model)
        return model
    }

    public func decode<T: Codable>(type: T.Type) throws -> T {
        let model: T = try Try {
            let decodedData = try JSONSerialization.data(withJSONObject: self.context)
            return try JSONDecoder().decode(type, from: decodedData) as T
        }.catchMapError { error in
            AarKayError.invalidContents(
                AarKayError.InvalidContentsReason.invalidModel
            )
        }
        return model
    }

    public mutating func setFileName(_ fileName: String) {
        self.fileName = fileName.failIfEmpty()
    }

    public mutating func setDirectory(_ directory: String?) {
        self.directory = directory.nilIfEmpty()
    }

    public mutating func setContext(_ context: [String: Any]) {
        self.context = context
    }

    public mutating func addContext(_ context: [String: Any]) {
        setContext(self.context + context)
    }

    public mutating func setContext<T: Encodable>(
        _ model: T,
        with context: [String: Any]? = nil
    ) throws {
        let object: Any? = try Try {
            let encodedData = try JSONEncoder().encode(model)
            return try JSONSerialization.jsonObject(
                with: encodedData,
                options: .allowFragments
            )
        }.catchMapError { error in
            AarKayError.invalidContents(
                AarKayError.InvalidContentsReason.invalidModel
            )
        }
        guard let obj = object as? [String: Any] else {
            throw AarKayError.internalError(
                "Could not decode collection from encoded data"
            )
        }
        if let context = context {
            setContext(obj + context)
        } else {
            setContext(obj)
        }
    }

    public mutating func setOverride(_ override: Bool) {
        self.override = override
    }

    public mutating func setSkip(_ skip: Bool) {
        self.skip = skip
    }

    public mutating func setTemplate(_ template: Template) {
        self.template = template
    }

    public mutating func setGlobalContext(_ globalContext: [String: Any]?) {
        self.globalContext = globalContext
    }
}
