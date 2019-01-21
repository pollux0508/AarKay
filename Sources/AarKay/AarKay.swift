//
//  AarKay.swift
//  AarKay
//
//  Created by RahulKatariya on 21/08/18.
//

import AarKayKit
import AarKayRunnerKit
import Foundation
import SharedKit

/// Represents an AarKay Project.
public class AarKay {
    /// The project url.
    let url: URL

    /// The options.
    let options: AarKayOptions

    /// The global.
    let global: AarKayGlobal

    /// The FileManager.
    let fileManager: FileManager

    /// The datafiles url relative to the project url.
    lazy var aarkayFilesUrl: URL = {
        url.appendingPathComponent("AarKay/AarKayData", isDirectory: true)
    }()

    /// The templatefiles url relative to the project url.
    lazy var aarkayTemplatesUrl: URL = {
        url.appendingPathComponent("AarKay/AarKayTemplates", isDirectory: true)
    }()

    /// Initializes an `AarKay` project.
    ///
    /// - Parameters:
    ///   - url: The url of project directory where files will be generated.
    ///   - options: The options.
    ///   - fileManager: The file manager.
    public init(
        url: URL,
        options: AarKayOptions = AarKayOptions(),
        fileManager: FileManager = FileManager.default
    ) {
        self.url = url
        self.options = options
        self.fileManager = fileManager
        self.global = AarKayGlobal(url: url, fileManager: fileManager)
    }

    /// Bootstrap files generation process.
    public func bootstrap() {
        /// Log the url and AarKayFiles url.
        AarKayLogger.logTable(url: url, datafilesUrl: aarkayFilesUrl)

        /// Log if the AarKayFiles directory is empty.
        guard fileManager.fileExists(atPath: aarkayFilesUrl.path) else {
            AarKayLogger.logNoDatafiles(); return
        }

        do {
            /// Skip checking whether directory is dirty if force is set to true
            if !options.force {
                if try fileManager.git.isDirty(url: url) {
                    AarKayLogger.logDirtyRepo(); return
                }
            }

            /// The global context to be applied to all files being generated.
            let globalContext = try global.context()
            let globalTemplatesUrl = global.templatesUrl(
                aarkayPaths: AarKayPaths.default
            )
            let templateUrls = [globalTemplatesUrl, aarkayTemplatesUrl]
                .compactMap { $0 }

            /// First level of subdirectories in AarKayFiles directory are the names of the plugins.
            let urls = try Try {
                try self.fileManager.contentsOfDirectory(
                    at: self.aarkayFilesUrl,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: .skipsHiddenFiles
                )
            }.catchMapError { error in
                AarKayError.internalError(
                    "Failed to fetch contents of directory at url - \(url.path)",
                    with: error
                )
            }

            urls.forEach {
                bootstrapPlugin(
                    pluginUrl: $0,
                    templateUrls: templateUrls,
                    globalContext: globalContext
                )
            }
        } catch {
            AarKayLogger.logError(error)
        }
    }

    private func bootstrapPlugin(
        pluginUrl: URL,
        templateUrls: [URL],
        globalContext: [String: Any]? = nil
    ) {
        let plugin = pluginUrl.lastPathComponent
        do {
            let aarkayKit = try AarKayKit(
                plugin: plugin,
                globalContext: globalContext,
                globalTemplates: templateUrls
            )

            /// Create directory tree mirror with source as the AarKayFiles url and destination as the project url.
            let dirTreeMirror = DirTreeMirror(
                sourceUrl: pluginUrl,
                destinationUrl: url,
                fileManager: fileManager
            )

            let mirrorUrls = try Try {
                try dirTreeMirror.bootstrap()
            }.catchMapError { error in
                AarKayError.internalError(
                    "Failed to create directory tree mirror with source url - \(pluginUrl) and destination url - \(url)",
                    with: error
                )
            }

            mirrorUrls.forEach { (sourceUrl: URL, destinationUrl: URL) in
                self.bootstrap(
                    aarkayKit: aarkayKit,
                    plugin: plugin,
                    globalContext: globalContext,
                    sourceUrl: sourceUrl,
                    destinationUrl: destinationUrl
                )
            }
        } catch {
            AarKayLogger.logFileErrored(
                at: pluginUrl,
                error: error,
                verbose: options.verbose
            )
        }
    }

    private func bootstrap(
        aarkayKit: AarKayKit,
        plugin: String,
        globalContext: [String: Any]?,
        sourceUrl: URL,
        destinationUrl: URL
    ) {
        /// Ignore the system dotfiles in AarKayFiles directory. Users can create custom dotfiles using string "dot" like 'dot.filename.yml' which will be generated as '.filename.ext'.
        guard !sourceUrl.lastPathComponent.hasPrefix(".") else { return }

        AarKayLogger.logDatafile(at: sourceUrl)

        /// All Datafiles will have atleast two components seperated by ".".
        /// The latter component will be the extension of type of serialization file like yml, json, exel and so on and the first component as the name of the template and the name of filename.
        ///
        /// For instance: -
        ///     1. Template.yml
        ///     2. gitignore.yml
        ///     3. CoreData.json
        ///
        /// The template name and the file name in this cases is same and always the first component - Template, gitignore, CoreData.
        ///
        /// However Datafiles can also have 3 components seperated by ".".
        ///
        /// For instance: -
        ///     1. Name.Template.yml
        ///     2. swift.gitignore.yml
        ///     3. DataModel.CoreData.json
        ///
        /// The template name in this case is the second component - Template, gitignore, CoreData and the filename will be the first component - Name, swift, DataModel.
        ///
        /// Return log error if the components are more than 3 or less than 2. A special case where components will be 4 is only when the first component is "dot" as the first "dot" is treated as actual ".".
        let components = sourceUrl.lastPathComponent.components(separatedBy: ".")
        if components.count < 2 ||
            components.count > 4 ||
            (components.count == 4 && components[0] != "dot") {
            AarKayLogger.logErrorMessage("Invalid Datafile name at \(sourceUrl.absoluteString)")
            return
        }

        /// Skip `dot` prefix if present.
        let name = components.count == 4 ? components[1] : components[0]
        let template = components[components.count - 2]
        let directory = sourceUrl.deletingLastPathComponent().relativeString
        do {
            /// Read the contents of the Datafile.
            let contents = try String(contentsOf: sourceUrl)

            /// Returns all generated files result.
            let renderedfiles = try aarkayKit.bootstrap(
                name: name,
                directory: directory,
                template: template,
                contents: contents
            )

            try renderedfiles.forEach { generatedfile in
                switch generatedfile {
                case .success(let value):
                    /// Create the file at the mirrored destination url with the generated contents.
                    try createFile(
                        generatedfile: value,
                        at: destinationUrl.deletingLastPathComponent()
                    )
                case .failure(let error):
                    AarKayLogger.logFileErrored(
                        at: sourceUrl,
                        error: error,
                        verbose: options.verbose
                    )
                }
            }
        } catch {
            AarKayLogger.logFileErrored(
                at: sourceUrl,
                error: error,
                verbose: options.verbose
            )
        }
    }

    /// Reads the current file at url and merges the contents of `RenderedFile` to it.
    ///
    /// - Parameters:
    ///   - generatedfile: The rendered file.
    ///   - url: The destination url.
    /// - Throws: FileManager operation errors.
    private func createFile(generatedfile: Generatedfile, at url: URL) throws {
        var url = url
        if let directory = generatedfile.directory {
            url = url
                .appendingPathComponent(directory, isDirectory: true)
                .standardized
        }
        url.appendPathComponent(generatedfile.nameWithExt)
        guard !generatedfile.skip else {
            if options.verbose {
                AarKayLogger.logFileSkipped(at: url)
            }
            return
        }
        if fileManager.fileExists(atPath: url.path) {
            if !generatedfile.override {
                if options.verbose {
                    AarKayLogger.logFileSkipped(at: url); return
                }
            } else {
                let currentString = try String(contentsOf: url)
                let string = generatedfile.merge(currentString)
                if string != currentString {
                    if !options.dryrun {
                        try Try { () -> Void in
                            try string.write(
                                to: url, atomically: true, encoding: .utf8
                            )
                        }.catchMapError { error in
                            AarKayError.internalError(
                                "Could not create file at url - \(url.path)",
                                with: error
                            )
                        }
                    }
                    AarKayLogger.logFileModified(at: url)
                } else {
                    if options.verbose {
                        AarKayLogger.logFileUnchanged(at: url)
                    }
                }
            }
        } else {
            if !options.dryrun {
                try Try { () -> Void in
                    try self.fileManager.createDirectory(
                        at: url.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try generatedfile.contents.write(
                        to: url, atomically: true, encoding: .utf8
                    )
                }.catchMapError { error in
                    AarKayError.internalError(
                        "Could not create file at url - \(url.path)",
                        with: error
                    )
                }
            }
            AarKayLogger.logFileAdded(at: url)
        }
    }
}
