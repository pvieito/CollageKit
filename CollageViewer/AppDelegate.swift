//
//  AppDelegate.swift
//  CollageViewer
//
//  Created by Pedro José Pereira Vieito on 26/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import LoggerKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let container = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            do {
            try "CollageViewer".write(to: container.appendingPathComponent("Documents").appendingPathComponent(".CollageViewer"), atomically: true, encoding: String.Encoding.ascii)
            }
            catch {
                Logger.log(error: error.localizedDescription)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {

        for path in filenames {
            NSDocumentController.shared.openDocument(withContentsOf: URL(fileURLWithPath: path), display: true, completionHandler: {_,_,_ in })
        }
    }

    /*func newDocument(_ sender: Any) {
        NSDocumentController.shared.openDocument(self)
    }*/

}

