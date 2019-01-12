//
//  AarKayKit.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 04/12/17.
//

import Foundation
import Result

public class AarKayKit {
    let datafile: Datafile
    let aarkayService: AarKayService
    let globalTemplates: [URL]?

    init(
        datafile: Datafile,
        aarkayService: AarKayService,
        globalTemplates: [URL]?
    ) {
        self.datafile = datafile
        self.aarkayService = aarkayService
        self.globalTemplates = globalTemplates
    }
}

extension AarKayKit {
    public static func bootstrap(
        plugin: String,
        globalContext: [String: Any]?,
        fileName: String,
        directory: String?,
        template: String,
        contents: String,
        globalTemplates: [URL]?
    ) throws -> [Result<Renderedfile, AnyError>] {
        let datafile = Datafile(
            plugin: plugin,
            name: fileName,
            directory: directory,
            template: template,
            contents: contents,
            globalContext: globalContext
        )

        let aarkayKit = AarKayKit(
            datafile: datafile,
            aarkayService: AarKayProvider(),
            globalTemplates: globalTemplates
        )

        return try aarkayKit.bootstrap()
    }
}

extension AarKayKit {
    func bootstrap() throws -> [Result<Renderedfile, AnyError>] {
        // 1.
        let templateClass = self.aarkayService.templateClass(
            plugin: self.datafile.plugin,
            template: self.datafile.template
        )
        
        var inputSerializer: InputSerializable!
        var templatesUrl: [URL]!
        if let templateClass = templateClass {
            inputSerializer = templateClass.inputSerializer()
            templatesUrl = [templateClass.resource().rk.templatesDirectory()]
        } else if let globalTemplates = globalTemplates {
            inputSerializer = YamlInputSerializer()
            templatesUrl = globalTemplates
        } else {
            throw AarKayError.templateNotFound(datafile.template)
        }
        
        var context: Any!
        do {
            context = try inputSerializer
                .context(contents: self.datafile.contents)
        } catch {
            throw AnyError(error)
        }

        // 2.
        var fileName: String?
        var contextArray: [[String: Any]]
        if self.datafile.name.rk.isCollection {
            fileName = nil
            contextArray = context as? [[String: Any]] ?? [[:]]
        } else {
            fileName = self.datafile.name
            contextArray = [context] as? [[String: Any]] ?? [[:]]
        }

        // 3.
        let generatedFiles = aarkayService.generatedfiles(
            datafile: datafile,
            fileName: fileName,
            contextArray: contextArray,
            templateClass: templateClass
        )

        // 4.
        return self.aarkayService.renderedFiles(
            urls: templatesUrl,
            generatedfiles: generatedFiles,
            context: self.datafile.globalContext
        )
    }
}
