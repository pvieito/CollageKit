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

        do {
            guard let collage = collage else {
                return
            }

            guard let imagesDirectoryURL = collage.imagesDirectoryURL else {
                return
            }

            let request = try SandboxRequest(url: imagesDirectoryURL)

            request.requestTemporaryAccess(window: self.view.window, completionHandler: { (error) in
                if let error = error {
                    self.presentError(error)
                }
                else {
                    self.renderCollage()
                }
            })
        }
        catch {
            self.presentError(error)
        }
    }

    func load(imageURL: URL) {
        self.imageView.isHidden = false

        self.imageView.setImageWith(imageURL)
    }

    func load(collage: CXFCollage) {
        self.collage = collage
        self.imageView.isHidden = true
    }

    func renderCollage() {
        self.activityIndicator.startAnimation(self)
        self.view.window?.title = self.collage?.albumTitle ?? "CollageViewer"

        self.collage?.render(completionHandler: { (image, error) in

            self.activityIndicator.stopAnimation(self)

            if let image = image {
                self.imageView.isHidden = false
                self.imageView.setImage(image, imageProperties: [:])
            }
            else if let error = error {
                self.imageView.isHidden = true
                self.presentError(error)
            }
        })
    }

    @discardableResult
    override func presentError(_ error: Error) -> Bool {

        Logger.log(error: error)
        if let window = self.view.window {
            self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
        }
        else {
            return super.presentError(error)
        }

        return false
    }
}

