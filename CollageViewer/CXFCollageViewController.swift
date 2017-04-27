//
//  ViewController.swift
//  CollageViewer
//
//  Created by Pedro José Pereira Vieito on 26/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import Quartz
import LoggerKit
import SandboxKit
import CollageKit

class CXFCollageViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    @IBOutlet weak var imageView: IKImageView!

    var collage: CXFCollage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.view.window?.delegate = self
        self.imageView.currentToolMode = IKToolModeMove

        guard let imagesDirectoryURL = collage?.imagesDirectoryURL else {
            Logger.log(error: "Images directory not found.")
            return
        }

        SBXSandboxManager.shared.requestAccess(url: imagesDirectoryURL, window: self.view.window) { (granted) in
            if granted {
                self.renderCollage()
            }
            else {
                Logger.log(error: "Access not granted.")
                self.activityIndicator.stopAnimation(self)

                if let window = self.view.window {
                    let alert = NSAlert()
                    alert.messageText = "Collage photos not accessible."
                    alert.informativeText = "Collage photos are stored in \(imagesDirectoryURL.path)."
                    alert.addButton(withTitle: "OK")
                    alert.beginSheetModal(for: window, completionHandler: { (response) in
                        self.view.window?.close()
                    })
                }
            }
        }
    }

    func load(collage: CXFCollage) {
        self.collage = collage

        self.imageView.isHidden = true
        self.activityIndicator.startAnimation(self)
        self.view.window?.title = collage.albumTitle
    }

    func renderCollage() {
        self.collage?.render(completionHandler: { (image) in

            self.activityIndicator.stopAnimation(self)

            guard let image = image else {
                self.imageView.isHidden = true
                Logger.log(error: "Collage did not render successfully.")
                return
            }

            self.imageView.isHidden = false
            self.imageView.setImage(image, imageProperties: [:])
        })
    }

    func requestAccess(to url: URL, completionHandler: @escaping (Bool) -> ()) {
        if FileManager.default.fileExists(atPath: url.path) {
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
            openPanel.allowsMultipleSelection = false
            openPanel.prompt = "Allow"
            openPanel.directoryURL = url

            if let window = view.window {
                openPanel.beginSheetModal(for: window) { response in
                    if response == NSModalResponseOK {
                        completionHandler(true)
                    }
                    else {
                        completionHandler(false)
                    }
                }
            }
        }
        else {
            completionHandler(false)
        }
    }
}

