//
//  CXFNode.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 23/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import CoreGraphics
import SWXMLHash
import LoggerKit

class CXFNode {

    private let nodeXML: XMLIndexer
    private let collage: CXFCollage

    private let theta: Double
    private let scale: Double
    private let proportionalRect: CGRect

    internal let imageURL: URL

    internal init?(element: XMLIndexer, collage: CXFCollage) {
        self.nodeXML = element
        self.collage = collage

        guard let xString = nodeXML.element?.attribute(by: "x")?.text, let x = Double(xString) else {
            return nil
        }

        guard let yString = nodeXML.element?.attribute(by: "y")?.text, let y = Double(yString) else {
            return nil
        }

        guard let widthString = nodeXML.element?.attribute(by: "w")?.text, let width = Double(widthString) else {
            return nil
        }

        guard let heightString = nodeXML.element?.attribute(by: "h")?.text, let height = Double(heightString) else {
            return nil
        }

        self.proportionalRect = CGRect(x: x, y: y, width: width, height: height)

        guard let thetaString = nodeXML.element?.attribute(by: "theta")?.text, let theta = Double(thetaString) else {
            return nil
        }

        self.theta = theta

        guard let scaleString = nodeXML.element?.attribute(by: "scale")?.text, let scale = Double(scaleString) else {
            return nil
        }

        self.scale = scale

        guard let imagePath = nodeXML["src"].element?.text else {
            return nil
        }

        self.imageURL = URL(fileURLWithPath: imagePath, relativeTo: collage.collageURL)
    }

    internal var collageArea: CGRect {
        let width = self.proportionalRect.width * (collage.size.width - collage.spacing) - collage.spacing
        let height = self.proportionalRect.height * (collage.size.height - collage.spacing) - collage.spacing

        let x = self.proportionalRect.origin.x * (collage.size.width - collage.spacing) + collage.spacing
        let y = collage.size.height - self.proportionalRect.origin.y * (collage.size.height - collage.spacing) - collage.spacing - height

        let collageArea = CGRect(x: x, y: y, width: width, height: height)

        Logger.log(debug: "Node \(imageURL.lastPathComponent) collage area: \(collageArea)")

        return collageArea
    }

    internal var image: CGImage? {
        Logger.log(debug: "Loading node image \(imageURL.lastPathComponent)...")

        if !FileManager.default.isReadableFile(atPath: self.imageURL.path) {

        }

        guard let source = CGImageSourceCreateWithURL(self.imageURL as CFURL, nil) else {
            Logger.log(warning: "Node image not found: \(imageURL.path)")
            return nil
        }

        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            Logger.log(warning: "Error creating image node: \(imageURL.path)")
            return nil
        }

        return image.cropping(ratio: self.collageArea.size)
    }
}

