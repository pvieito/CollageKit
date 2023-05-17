//
//  main.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 21/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import CoreGraphicsKit
import LoggerKit
import ArgumentParser
import CollageKit

struct CollageTool: ParsableCommand {
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: String(describing: Self.self))
    }

    @Option(name: .shortAndLong, help: "Input collage file.")
    var input: String
    
    @Flag(name: .shortAndLong, help: "Verbose mode.")
    var verbose: Bool = false
    
    func run() throws {
        Logger.logMode = .commandLine
        Logger.logLevel = self.verbose ? .debug : .info
        
        do {
            let collage = try Collage(contentsOf: self.input.pathURL)
            Logger.log(important: collage.name)
            Logger.log(info: "Title: \(collage.albumTitle ?? "--")")
            Logger.log(info: "Date: \(collage.albumDate ?? "--")")
            
            if let imagesDirectoryURL = collage.imagesDirectoryURL {
                Logger.log(verbose: "Images Directory: \(imagesDirectoryURL.path)")
            }
            
            #if canImport(CoreGraphics)
            try collage.render().open()
            #endif
        }
        catch {
            Logger.log(fatalError: error)
        }
    }
}

CollageTool.main()
