//
//  AarKayGitExtensions.swift
//  AarKay
//
//  Created by RahulKatariya on 22/12/18.
//

import Foundation

/// Describes a provider of git extensions.
protocol GitExtensionsProvider {}

extension GitExtensionsProvider {
    /// A proxy which hosts git extensions for `self`.
    var git: Git<Self> {
        return Git(self)
    }

    /// A proxy which hosts static git extensions for the type of `self`.
    static var git: Git<Self>.Type {
        return Git<Self>.self
    }
}

/// A proxy which hosts reactive extensions of `Base`.
struct Git<Base> {
    /// The `Base` instance the extensions would be invoked with.
    let base: Base

    /// Construct a proxy
    ///
    /// - parameters:
    ///   - base: The object to be proxied.
    fileprivate init(_ base: Base) {
        self.base = base
    }
}
