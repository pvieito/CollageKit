//
//  CXFDocument.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 26/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import CollageKit
import CoreGraphicsKit
import LoggerKit

class CXFDocument: NSDocument {
    var collage: CXFCollage? = nil
    var imageURL: URL? = nil

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "windowController") as! NSWindowController

        self.addWindowController(windowController)

        if let viewController = self.windowControllers.first?.window?.contentViewController as? CXFViewController {

            if let collage = self.collage {
                viewController.load(collage: collage)
            }
            else if let imageURL = imageURL {
                viewController.load(imageURL: imageURL)
            }
        }
    }

    override func read(from url: URL, ofType typeName: String) throws {
        switch typeName {
        case "public.jpeg":
            self.imageURL = url
        case "com.google.picasa.collage":
            do {
                self.collage = try CXFCollage(contentsOf: url)
            }
            catch {
                Logger.log(error: error.localizedDescription)
                let alert = NSAlert(error: error)
                alert.runModal()
                throw error
            }
        default:
            throw NSError(domain: "com.pvieito.CollageViewer.open", code: -3, userInfo: nil)
        }
    }

    override func saveAs(_ sender: Any?) {
        if let window = self.windowForSheet, let image = collage?.image {
            let savePanel = NSSavePanel()

            savePanel.directoryURL = self.fileURL?.deletingLastPathComponent()
            savePanel.allowedFileTypes = ["jpg"]
            savePanel.nameFieldStringValue = self.fileURL?.deletingPathExtension().appendingPathExtension("jpg").lastPathComponent ?? ""

            savePanel.beginSheetModal(for: window) { (result) in
                if result == .OK, let url = savePanel.url {
                    do {
                        try image.write(to: url)
                    }
                    catch {
                        Logger.log(error: error)
                    }
                }
            }
        }
    }
}
