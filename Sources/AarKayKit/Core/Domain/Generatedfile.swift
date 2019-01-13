//
//  Generatedfile.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 31/12/17.
//

import Foundation

public struct Generatedfile {
    public private(set) var plugin: String
    public private(set) var name: String
    public private(set) var directory: String?
    public private(set) var contents: [String: Any]?
    public private(set) var override: Bool
    public private(set) var template: String
    public private(set) var templateString: String?
    public private(set) var ext: String?

    public init(
        plugin: String,
        name: String,
        directory: String?,
        contents: [String: Any]?,
        override: Bool,
        template: String
    ) {
        self.plugin = plugin.failIfEmpty()
        self.directory = directory.nilIfEmpty()
        self.name = name.failIfEmpty()
        self.contents = contents
        self.override = override
        self.template = template
    }
    
    public mutating func setPlugin(_ plugin: String) {
        self.plugin = plugin.failIfEmpty()
    }
    
    public mutating func setName(_ name: String) {
        self.name = name.failIfEmpty()
    }
    
    public mutating func setDirectory(_ directory: String?) {
        self.directory = directory.nilIfEmpty()
    }
    
    public mutating func setContents(_ contents: [String: Any]?) {
        self.contents = contents//.nilIfEmpty()
    }
    
    public mutating func setOverride(_ override: Bool) {
        self.override = override
    }
    
    public mutating func setTemplate(_ template: String) {
        self.template = template
    }
    
    public mutating func setTemplateString(_ templateString: String?) {
        self.templateString = templateString.nilIfEmpty()
    }
    
    public mutating func setExt(_ ext: String?) {
        self.ext = ext.nilIfEmpty()
    }
}
