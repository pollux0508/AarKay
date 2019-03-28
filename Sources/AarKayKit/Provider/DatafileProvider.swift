//
//  DatafileProvider.swift
//  AarKay
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import SharedKit

struct DatafileProvider: DatafileService {
    func serialize(
        plugin: String,
        name: String,
        directory: String,
        template: String,
        contents: String,
        using serializer: InputSerializable,
        globalContext: [String: Any]?
    ) throws -> [Result<Datafile, Error>] {
        var context = try serializer.context(contents: contents)
        if name.isCollection {
            if contents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                context = [[:]]
            }
            guard let contextArray = context as? [[String: Any]] else {
                throw AarKayKitError.invalidContents(
                    AarKayKitError.InvalidContentsReason.arrayExpected
                )
            }
            return datafiles(
                plugin: plugin,
                directory: directory,
                contextArray: contextArray,
                template: template,
                globalContext: globalContext
            )
        } else {
            if contents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                context = [:]
            }
            guard let context = context as? [String: Any] else {
                throw AarKayKitError.invalidContents(
                    AarKayKitError.InvalidContentsReason.objectExpected
                )
            }
            let df = datafile(
                fileName: name,
                directory: directory,
                context: context,
                template: template,
                globalContext: globalContext
            )
            return [Result<Datafile, Error>.success(df)]
        }
    }

    func templateDatafiles(
        datafile: Datafile,
        templateClass: Templatable.Type
    ) throws -> [Datafile] {
        let templatable = try templateClass.init(
            datafile: datafile
        )
        let datafiles = try templatable.datafiles()
        return datafiles
    }
}

// MARK: - Private Helpers

extension DatafileProvider {
    private func datafile(
        fileName: String,
        directory: String,
        context: [String: Any],
        template: String,
        globalContext: [String: Any]?
    ) -> Datafile {
        let fileName = context.fileName() ?? fileName
        var dir = directory
        if let dirName = context.dirName() {
            dir = dir + "/" + dirName
        }
        return Datafile(
            fileName: fileName.standardized,
            directory: dir,
            template: .name(template),
            globalContext: globalContext,
            context: context,
            override: context.override(),
            skip: context.skip()
        )
    }

    private func datafiles(
        plugin: String,
        directory: String,
        contextArray: [[String: Any]],
        template: String,
        globalContext: [String: Any]?
    ) -> [Result<Datafile, Error>] {
        return contextArray.map { context -> Result<Datafile, Error> in
            Result<Datafile, Error> {
                guard let fileName = context.fileName() ?? context.name() else {
                    throw AarKayKitError.invalidContents(
                        AarKayKitError.InvalidContentsReason.missingFileName
                    )
                }
                return datafile(
                    fileName: fileName,
                    directory: directory,
                    context: context,
                    template: template,
                    globalContext: globalContext
                )
            }
        }
    }
}

extension String {
    fileprivate var standardized: String {
        return replacingOccurrences(of: ".", with: ":")
            .replacingOccurrences(of: "dot:", with: ".")
            .components(separatedBy: ":")
            .first!
    }

    fileprivate var isCollection: Bool {
        return hasPrefix("[") && hasSuffix("]")
    }
}

extension Dictionary where Key == String, Value == Any {
    fileprivate func fileName() -> String? {
        return self["_fn"] as? String
    }

    fileprivate func name() -> String? {
        return self["name"] as? String
    }

    fileprivate func dirName() -> String? {
        return self["_dn"] as? String
    }

    fileprivate func override() -> Bool {
        return self["_or"] as? Bool ?? true
    }

    fileprivate func skip() -> Bool {
        return self["_skip"] as? Bool ?? false
    }
}
