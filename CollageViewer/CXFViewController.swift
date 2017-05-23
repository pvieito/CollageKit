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

class CXFViewController: NSViewController, NSWindowDelegate {

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


        guard let collage = collage else {
            Logger.log(debug: "Collage not set.")
            return
        }

        guard let imagesDirectoryURL = collage.imagesDirectoryURL else {
            Logger.log(error: "Images directory not found.")
            return
        }

        SandboxManager.shared.requestAccess(url: imagesDirectoryURL, window: self.view.window) { (error) in
            if let error = error {
                Logger.log(error: error)
                self.activityIndicator.stopAnimation(self)

                if let window = self.view.window {
                    let alert = NSAlert()
                    alert.messageText = "Collage photos not accessible"
                    alert.informativeText = error.localizedDescription
                    alert.addButton(withTitle: "OK")
                    alert.beginSheetModal(for: window, completionHandler: { (response) in
                        self.view.window?.close()
                    })
                }
            }
            else {
                self.renderCollage()
            }
        }

        func printResponderChain(from responder: NSResponder?) {
            var responder = responder
            while let r = responder {
                print(r)
                responder = r.nextResponder
            }
        }
        
        
        printResponderChain(from: view)
    }

    func load(imageURL: URL) {
        self.imageView.isHidden = false

        self.imageView.setImageWith(imageURL)
    }

    func load(collage: CXFCollage) {
        self.collage = collage

        self.imageView.isHidden = true
        self.activityIndicator.startAnimation(self)
        self.view.window?.title = collage.albumTitle ?? "CollageViewer"
    }

    func renderCollage() {
        self.collage?.render(completionHandler: { (image) in

            self.activityIndicator.stopAnimation(self)

            guard let image = image else {
                self.imageView.isHidden = true

                if let window = self.view.window {
                    let alert = NSAlert()
                    alert.messageText = "Collage did not render successfully"
                    alert.addButton(withTitle: "OK")
                    alert.beginSheetModal(for: window, completionHandler: { (response) in
                        self.view.window?.close()
                    })
                }
                return
            }

            self.imageView.isHidden = false
            self.imageView.setImage(image, imageProperties: [:])
        })
    }

    func printDocument(_ sender: Any) {
        Logger.log(debug: "??")
    }
}

