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

    /// The FileManager.
    let fileManager: FileManager

    /// The global.
    public let global: AarKayGlobal

    /// The datafiles url relative to the project url.
    public lazy var aarkayFilesUrl: URL = {
        url.appendingPathComponent("AarKay/AarKayData", isDirectory: true)
    }()

    /// The templates url relative to the project url.
    public lazy var aarkayTemplatesUrl: URL = {
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
            let globalTemplatesUrl = global.templatesUrl()
            let templateUrls: Set<URL> = [globalTemplatesUrl, aarkayTemplatesUrl]

            /// First level of subdirectories in AarKayFiles directory are the names of the plugins.
            let urls = try Try {
                try self.fileManager.contentsOfDirectory(
                    at: self.aarkayFilesUrl,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: .skipsHiddenFiles
                )
            }.do { error in
                AarKayError.internalError(
                    "Failed to fetch contents of directory at url - \(url.relativeString)",
                    with: error
                )
            }

            urls.forEach {
                bootstrapPlugin(
                    pluginUrl: $0,
                    templateUrls: Array(templateUrls),
                    globalContext: globalContext
                )
            }
        } catch {
            AarKayLogger.logError(
                error,
                options: options
            )
        }
    }

    private func bootstrapPlugin(
        pluginUrl: URL,
        templateUrls: [URL],
        globalContext: [String: Any]? = nil
    ) {
        let pluginName = pluginUrl.lastPathComponent
        do {
            AarKayLogger.logPluginfile(at: pluginUrl)

            let plugin = try Pluginfile(
                name: pluginName,
                globalContext: globalContext?[pluginName.lowercased()] as? [String: Any],
                globalTemplates: templateUrls
            )

            let generatedFiles = try plugin.bootstrap()
            try generateFiles(
                sourceUrl: pluginUrl,
                destination: url,
                generatedFiles: generatedFiles
            )

            /// Create directory tree mirror with source as the AarKayFiles url and destination as the project url.
            let dirTreeMirror = DirTreeMirror(
                sourceUrl: pluginUrl,
                destinationUrl: url,
                fileManager: fileManager
            )

            let mirrorUrls = try Try {
                try dirTreeMirror.bootstrap()
            }.do { error in
                AarKayError.internalError(
                    "Failed to create directory tree mirror with source url - \(pluginUrl) and destination url - \(url)",
                    with: error
                )
            }

            mirrorUrls.forEach { (sourceUrl: URL, destinationUrl: URL) in
                self.bootstrap(
                    plugin: plugin,
                    sourceUrl: sourceUrl,
                    destinationUrl: destinationUrl
                )
            }
        } catch {
            AarKayLogger.logFileErrored(
                at: pluginUrl,
                error: error,
                options: options
            )
        }
    }

    private func bootstrap(
        plugin: Pluginfile,
        sourceUrl: URL,
        destinationUrl: URL
    ) {
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
            AarKayLogger.logErrorMessage(
                "Invalid Datafile name at \(sourceUrl.absoluteString)",
                options: options
            )
            return
        }

        /// Skip `dot` prefix if present.
        let name = components.count == 4 ? components[1] : components[0]
        let template = components[components.count - 2]
        let directory = sourceUrl.deletingLastPathComponent().relativeString
        guard let destination = destinationUrl.baseURL else {
            let error = AarKayError.internalError(
                "Failed to resolve the destination directory"
            )
            AarKayLogger.logFileErrored(
                at: sourceUrl,
                error: error,
                options: options
            )
            return
        }
        do {
            /// Read the contents of the Datafile.
            let contents = try String(contentsOf: sourceUrl)

            /// Returns all generated files result.
            let generatedFiles = try plugin.generate(
                fileName: name,
                directory: directory,
                template: template,
                contents: contents
            )

            try generateFiles(
                sourceUrl: sourceUrl,
                destination: destination,
                generatedFiles: generatedFiles
            )
        } catch {
            AarKayLogger.logFileErrored(
                at: sourceUrl,
                error: error,
                options: options
            )
        }
    }

    private func generateFiles(
        sourceUrl: URL,
        destination: URL,
        generatedFiles: [Result<Generatedfile, Error>]
    ) throws {
        try generatedFiles.forEach { generatedfile in
            switch generatedfile {
            case .success(let value):
                /// Create the file at the mirrored destination url with the generated contents.
                try createFile(generatedfile: value, at: destination)
            case .failure(let error):
                AarKayLogger.logFileErrored(
                    at: sourceUrl,
                    error: error,
                    options: options
                )
            }
        }
    }

    /// Reads the current file at url and merges the contents of `RenderedFile` to it.
    ///
    /// - Parameters:
    ///   - generatedfile: The rendered file.
    ///   - url: The destination url.
    /// - Throws: FileManager operation errors.
    private func createFile(generatedfile: Generatedfile, at url: URL) throws {
        let destination = URL(
            fileURLWithPath: generatedfile.datafile.directory,
            isDirectory: true,
            relativeTo: url
        )
        .appendingPathComponent(generatedfile.nameWithExt)
        .standardized
        guard !generatedfile.datafile.skip else {
            if options.verbose {
                AarKayLogger.logFileSkipped(at: url)
            }
            return
        }
        if fileManager.fileExists(atPath: destination.path) {
            if !generatedfile.datafile.override {
                if options.verbose {
                    AarKayLogger.logFileSkipped(at: url); return
                }
            } else {
                let currentString = try Try {
                    try String(contentsOf: destination)
                }.do { error in
                    AarKayError.internalError(
                        "Failed to read file at url - \(url)",
                        with: error
                    )
                }
                let string = try generatedfile.merge(currentString)
                if string != currentString {
                    if !options.dryrun {
                        try Try { () -> Void in
                            try string.write(
                                to: destination, atomically: true, encoding: .utf8
                            )
                        }.do { error in
                            AarKayError.internalError(
                                "Failed to create file at url - \(url.relativeString)",
                                with: error
                            )
                        }
                    }
                    AarKayLogger.logFileModified(at: destination)
                } else {
                    if options.verbose {
                        AarKayLogger.logFileUnchanged(at: destination)
                    }
                }
            }
        } else {
            if !options.dryrun {
                try Try { () -> Void in
                    try self.fileManager.createDirectory(
                        at: destination.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try generatedfile.contents.write(
                        to: destination, atomically: true, encoding: .utf8
                    )
                }.do { error in
                    AarKayError.internalError(
                        "Could not create file at url - \(destination.relativeString)",
                        with: error
                    )
                }
            }
            AarKayLogger.logFileAdded(at: destination)
        }
    }
}
