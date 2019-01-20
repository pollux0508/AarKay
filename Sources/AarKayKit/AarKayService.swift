//
//  AarKayService.swift
//  AarKayKit
//
//  Created by RahulKatariya on 20/10/18.
//

import Foundation
import Result

protocol AarKayService {
    var datafileService: DatafileService { get set }
    var generatedfileService: GeneratedfileService { get set }

    func templateClass(
        plugin: String,
        template: String
    ) -> Templatable.Type?
}

protocol DatafileService {
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
    ) throws -> [Datafile]
}

protocol GeneratedfileService {
    var aarkayTemplates: AarKayTemplates? { get set }

    func generatedfiles(
        templatefiles: Templatefiles,
        datafiles: [Result<Datafile, AnyError>],
        globalContext: [String: Any]?
    ) -> [Result<Generatedfile, AnyError>]
}
