//
//  DatafileProvider.swift
//  AarKay
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import Result

struct DatafileProvider: DatafileService {
    func serialize(
        plugin: String,
        name: String,
        template: String,
        contents: String,
        globalContext: [String: Any]?,
        using serializer: InputSerializable
    ) throws -> [Result<Datafile, AnyError>] {
        let context = try serializer.context(contents: contents)
        if name.isCollection {
            let contextArray = context as? [[String: Any]] ?? [[:]]
            return datafiles(
                plugin: plugin,
                contextArray: contextArray,
                template: template,
                globalContext: globalContext
            )
        } else {
            let context = context as? [String: Any] ?? [:]
            let df = datafile(
                fileName: name,
                context: context,
                template: template,
                globalContext: globalContext
            )
            return [Result<Datafile, AnyError>.success(df)]
        }
    }

    func templateDatafiles(
        datafile: Datafile,
        templateClass: Templatable.Type
    ) -> [Result<Datafile, AnyError>] {
        let result = Result<[Datafile], AnyError> {
            let templatable = try templateClass.init(
                datafile: datafile
            )
            let datafiles = try templatable.datafiles()
            return datafiles
        }
        switch result {
        case .success(let files):
            return files.map { Result<Datafile, AnyError>.success($0) }
        case .failure(let error):
            return [Result<Datafile, AnyError>.failure(error)]
        }
    }
}

// MARK: - Private Helpers

extension DatafileProvider {
    private func datafile(
        fileName: String,
        context: [String: Any],
        template: String,
        globalContext: [String: Any]?
    ) -> Datafile {
        let fileName = context.fileName() ?? fileName
        return Datafile(
            fileName: fileName.standardized,
            directory: context.dirName(),
            context: context,
            override: context.override(),
            skip: context.skip(),
            template: .name(template),
            globalContext: globalContext
        )
    }

    private func datafiles(
        plugin: String,
        contextArray: [[String: Any]],
        template: String,
        globalContext: [String: Any]?
    ) -> [Result<Datafile, AnyError>] {
        return contextArray.map { context -> Result<Datafile, AnyError> in
            Result<Datafile, AnyError> {
                guard let fileName = context.fileName() ?? context.name() else {
                    throw AarKayError.missingFileName(plugin, template)
                }
                return datafile(
                    fileName: fileName,
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
