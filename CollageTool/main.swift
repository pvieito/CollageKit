//
//  main.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 21/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import FoundationKit
import CoreGraphicsKit
import LoggerKit
import CommandLineKit
import CollageKit

let collagesOption = StringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input collage file.")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(collagesOption, verboseOption, helpOption)

do {
    try cli.parse(strict: true)
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

guard let collagePath = collagesOption.value?.pathURL else {
    Logger.log(error: "No input files specified.")
    exit(EX_USAGE)
}

do {
    let collage = try Collage(contentsOf: collagePath)
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
