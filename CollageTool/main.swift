//
//  main.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 21/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import CoreGraphics
import CoreGraphicsKit
import LoggerKit
import CommandLineKit
import CollageKit

let collagesOption = MultiStringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input collage files (.cxf extension).")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(collagesOption, verboseOption, helpOption)

do {
    try cli.parse()
}
catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.value {
    cli.printUsage()
    exit(0)
}

Logger.logMode = .commandLine
Logger.logLevel = verboseOption.value ? .debug : .info


guard let collagePaths = collagesOption.value, collagePaths.count > 0 else {
    Logger.log(error: "No input files specified.")
    exit(EX_USAGE)
}

for collagePath in collagePaths {
    do {
        let collage = try CXFCollage(contentsOf: collagePath)
        Logger.log(important: collage.name)
        Logger.log(info: "Title: \(collage.albumTitle ?? "--")")
        Logger.log(info: "Date: \(collage.albumDate ?? "--")")
        Logger.log(info: "Size: \(collage.size)")

        let image = try collage.render()

        let imageURL = try image.temporaryFile()
        NSWorkspace.shared().open(imageURL)
    }
    catch {
        Logger.log(error: error)
    }
}
