//
//  AarKayService.swift
//  AarKayKit
//
//  Created by RahulKatariya on 20/10/18.
//

import Foundation
import Result

protocol AarKayService {
    func templateClass(
        plugin: String,
        template: String
    ) -> Templatable.Type?

    func serialize(
        plugin: String,
        name: String,
        template: String,
        contents: String,
        globalContext: [String: Any]?,
        using serializer: InputSerializable
    ) throws -> [Result<Datafile, AnyError>]

    func templateDatafiles(
        datafile: Datafile,
        templateClass: Templatable.Type
    ) -> [Result<Datafile, AnyError>]

    func generatedFiles(
        urls: [URL],
        datafiles: [Result<Datafile, AnyError>],
        globalContext: [String: Any]?
    ) -> [Result<GeneratedFile, AnyError>]
}
