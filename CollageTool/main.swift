//
//  main.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 21/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import CoreGraphics
import LoggerKit
import Commander
import CollageKit

Logger.logMode = .commandLine

let filesArgument = VariadicArgument<String>("collage")
let verboseFlag = Flag("verbose", flag: "v", description: "Verbose Mode", default: false)

let main = command(filesArgument, verboseFlag) { collagePaths, verbose in

    Logger.logLevel = verbose ? .debug : .info

    guard collagePaths.count > 0 else {
        Logger.log(error: "No input files specified.")
        exit(-1)
    }

    for collagePath in collagePaths {
        if let collage = CXFCollage(contentsOf: collagePath) {
            Logger.log(important: collage.name)
            Logger.log(info: "Title: \(collage.albumTitle)")
            Logger.log(info: "Date: \(collage.albumDate)")
            Logger.log(info: "Size: \(collage.size)")

            collage.render()

            if let imageURL = collage.saveImageTemporary() {
                NSWorkspace.shared().open(imageURL)
            }
        }
        else {
            Logger.log(error: "No collage file found at \(collagePath).")
        }
    }
}

main.run()
