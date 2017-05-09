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

    private let scale: CGFloat
    private let proportionalRect: CGRect

    internal let theta: CGFloat
    internal var collageArea: CGRect

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

        self.theta = CGFloat(theta)

        guard let scaleString = nodeXML.element?.attribute(by: "scale")?.text, let scale = Double(scaleString) else {
            return nil
        }

        self.scale = CGFloat(scale)

        guard let imagePath = nodeXML["src"].element?.text else {
            return nil
        }

        self.imageURL = collage.imageURL(from: imagePath)

        let areaWidth = self.proportionalRect.width * (collage.size.width - collage.spacing) - collage.spacing
        let areaHeight = self.proportionalRect.height * (collage.size.height - collage.spacing) - collage.spacing

        let areaX = self.proportionalRect.origin.x * (collage.size.width - collage.spacing) + collage.spacing
        let areaY = collage.size.height - self.proportionalRect.origin.y * (collage.size.height - collage.spacing) - collage.spacing - areaHeight

        let collageArea = CGRect(x: areaX, y: areaY, width: areaWidth, height: areaHeight)

        Logger.log(debug: "Node \(imageURL.lastPathComponent) collage area: \(collageArea)")

        self.collageArea = collageArea
    }

    internal var topLeftCenteredArea: CGRect {
        return CGRect(x: 0, y: 0, width: self.collageArea.width, height: -self.collageArea.height)
    }

    internal var image: CGImage? {
        Logger.log(debug: "Loading node image \(imageURL.lastPathComponent)...")

        return CGImage.init(url: self.imageURL, croppingRatio: self.collageArea.size)
    }
}

