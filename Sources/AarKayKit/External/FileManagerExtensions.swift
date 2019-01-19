//
//  URLExtensions.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 26/06/18.
//

import Foundation

extension FileManager {
    public func subDirectories(at url: URL) throws -> [URL] {
        let results = try directoryEnumerator(at: url)
            .map { $0 as! URL }
            .filter { try isDirectory(url: $0) }
        return results
    }

    public func subDirectories(at urls: [URL]) throws -> [URL] {
        return try urls.reduce(initial: urls) { try subDirectories(at: $0) }
    }

    public func subFiles(at url: URL) throws -> [URL] {
        let results = try directoryEnumerator(at: url)
            .map { $0 as! URL }
            .filter { !(try isDirectory(url: $0)) }
        return results
    }

    public func subFiles(at urls: [URL]) throws -> [URL] {
        return try urls.reduce { try subFiles(at: $0) }
    }

    private func isDirectory(url: URL) throws -> Bool {
        #if os(Linux)
        var isDir: ObjCBool = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDir) {
            return isDir.boolValue
        } else {
            throw AarKayError.internalError(
                "Failed to fetch isDirectory for \(url.absoluteString)"
            )
        }
        #else
        do {
            guard let isDir = try url.resourceValues(forKeys: [.isDirectoryKey])
                .isDirectory else {
                throw AarKayError.internalError(
                    "Failed to fetch isDirectory for \(url.absoluteString)"
                )
            }
            return isDir
        } catch {
            throw AarKayError.internalError(
                "Failed to fetch resource value for \(url.absoluteString)"
            )
        }
        #endif
    }
}

// MARK: - Private Helpers

extension FileManager {
    fileprivate func directoryEnumerator(at url: URL) throws -> DirectoryEnumerator {
        guard let enumerator = self.enumerator(
            at: url, includingPropertiesForKeys: [.isDirectoryKey]
        ) else {
            throw AarKayError.internalError(
                "Failed to create directory enumerator at \(url.absoluteString)"
            )
        }
        return enumerator
    }
}

extension Array {
    fileprivate func reduce(
        initial: [Element]? = nil,
        block: (Element) throws -> [Element]
    ) throws -> [Element] {
        return try reduce(
            initial ?? [Element]()
        ) { (initial: [Element], next: Element) -> [Element] in
            let items = try block(next)
            return initial + items
        }
    }
}
