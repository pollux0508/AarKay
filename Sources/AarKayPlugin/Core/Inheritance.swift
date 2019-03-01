//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Inheritance: NSObject, Templatable {
    public var datafile: Datafile
    private var model: InheritanceModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: InheritanceModel.self)
    }
}

public class InheritanceModel: Codable {
    public var base: String?
    public var inputSerializer: String?
    public var templateModel: TemplateModel
    public var templates: [TemplateStringModel]?
    public var subModels: [InheritanceModel]?

    private enum CodingKeys: String, CodingKey {
        case base
        case inputSerializer
        case templateModel
        case templates
        case subModels
    }

    public init(templateModel: TemplateModel) {
        self.templateModel = templateModel
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.base = try container.decodeIfPresent(String.self, forKey: .base)
        self.inputSerializer = try container.decodeIfPresent(String.self, forKey: .inputSerializer)
        self.templateModel = try container.decode(TemplateModel.self, forKey: .templateModel)
        self.templates = try container.decodeIfPresent([TemplateStringModel].self, forKey: .templates)
        self.subModels = try container.decodeIfPresent([InheritanceModel].self, forKey: .subModels)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(base, forKey: .base)
        try container.encodeIfPresent(inputSerializer, forKey: .inputSerializer)
        try container.encode(templateModel, forKey: .templateModel)
        try container.encodeIfPresent(templates, forKey: .templates)
        try container.encodeIfPresent(subModels, forKey: .subModels)
    }
}

// MARK: - AarKayEnd
extension Inheritance {
    public func datafiles() throws -> [Datafile] {
        var all = [Datafile]()
        var templateDatafile = datafile
        templateDatafile.setDirectory("AarKay/AarKayTemplates")
        templatefiles(
            datafile: templateDatafile,
            model: model,
            all: &all
        )
        try modelFiles(
            datafile: datafile,
            model: model,
            all: &all
        )
        return all
    }
    
    func templatefiles(
        datafile: Datafile,
        model: InheritanceModel,
        all: inout [Datafile]
    ) {
        model.templates?.forEach {
            let fileName = model.templateModel.name + ($0.suffix ?? "")
            let templateString = $0.string.replacingOccurrences(
                of: "{{self.name}}", with: model.templateModel.name
            )
            var subDf = datafile
            let ext: String = $0.ext.nilIfEmpty() != nil ? "\($0.ext!).stencil" : "stencil"
            subDf.setTemplate(.nameStringExt(datafile.template.name(), templateString, ext))
            subDf.setFileName(fileName)
            all.append(subDf)
        }
        
        guard let subs = model.subModels else { return }
        
        subs.forEach {
            let sub = $0
            if sub.templates == nil && model.templates != nil {
                sub.templates = model.templates!.map { t in
                    if let substring = t.subString {
                        let template = t
                        template.string = substring
                        return template
                    } else {
                        return t
                    }
                }
            }
            var subFile = datafile
            subFile.appendDirectory(model.templateModel.name)
            templatefiles(
                datafile: subFile,
                model: sub,
                all: &all
            )
        }
    }
    
    func modelFiles(
        datafile: Datafile,
        model: InheritanceModel,
        all: inout [Datafile]
    ) throws {
        var dFile = datafile
        dFile.setFileName(model.templateModel.name)
        all.append(dFile)
        
        guard let subs = model.subModels else { return }
        try subs.forEach { sub in
            sub.base = (model.templateModel.properties.isEmpty) ? model.base : model.templateModel.name
            sub.templateModel.baseProperties = model.templateModel.baseProperties + model.templateModel.properties
            var subFile = datafile
            subFile.appendDirectory(model.templateModel.name)
            try subFile.setContext(sub.templateModel)
            try modelFiles(datafile: subFile, model: sub, all: &all)
        }
    }
}
