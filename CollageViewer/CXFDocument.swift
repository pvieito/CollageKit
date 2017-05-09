//
//  CXFDocument.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 26/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import CollageKit
import LoggerKit

class CXFDocument: NSDocument {

    var collage: CXFCollage? = nil

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "windowController") as! NSWindowController

        self.addWindowController(windowController)

        if let viewController = self.windowControllers.first?.window?.contentViewController as? CXFCollageViewController, let collage = self.collage {
            viewController.load(collage: collage)
        }
    }

    override func read(from url: URL, ofType typeName: String) throws {
        do {
            self.collage = try CXFCollage(contentsOf: url)
        }
        catch {
            Logger.log(error: error.localizedDescription)
            let alert = NSAlert(error: error)
            alert.runModal()
            throw error
        }
    }

    override func saveAs(_ sender: Any?) {
        self.save(sender)
    }

    override func saveTo(_ sender: Any?) {
        self.save(sender)
    }

    override func save(_ sender: Any?) {

        if let window = self.windowControllers.first?.window, let image = collage?.image {
            let savePanel = NSSavePanel()

            savePanel.directoryURL = self.fileURL?.deletingLastPathComponent()
            savePanel.allowedFileTypes = ["jpg"]
            savePanel.nameFieldStringValue = self.fileURL?.deletingPathExtension().appendingPathExtension("jpg").lastPathComponent ?? ""

            savePanel.beginSheetModal(for: window) { (result) in
                if result == NSFileHandlingPanelOKButton, let url = savePanel.url {
                    image.write(at: url)
                }
            }
        }
    }
}
