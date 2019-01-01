//
//  Update.swift
//  AarKayRunner
//
//  Created by Rahul Katariya on 04/03/18.
//

import Foundation
import Commandant
import Result
import Curry

/// Type that encapsulates the configuration and evaluation of the `update` subcommand.
struct UpdateCommand: CommandProtocol {
    struct Options: OptionsProtocol {
        let global: Bool
        
        public static func evaluate(_ mode: CommandMode) -> Result<Options, CommandantError<AarKayError>> {
            return curry(self.init)
                <*> mode <| Switch(flag: "g", key: "global", usage: "Uses global version of `aarkay`.")
        }
    }

    var verb: String = "update"
    var function: String = "Update all the plugins from `AarKayFile`."
    
    func run(_ options: Options) -> Result<(), AarKayError> {
        var runnerUrl = URL.runnerPath()
        var global = false
        
        if !FileManager.default.fileExists(atPath: runnerUrl.path) || options.global {
            runnerUrl = URL.runnerPath(global: true)
            global = true
        }
        
        guard FileManager.default.fileExists(atPath: runnerUrl.path) else {
            return .failure(.missingProject(runnerUrl.deletingLastPathComponent().path))
        }
        
        do {
            try Runner.updatePackageSwift(global: global)
        } catch {
            return .failure(.bootstap(error))
        }
        println("Updating Plugins at \(runnerUrl.path). This might take a few minutes...")
        return Tasks.update(at: runnerUrl.path)
    }
}
