//
//  CXFNode.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 23/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

#if false
import Foundation
import CoreGraphics
import CoreGraphicsKit
import SWXMLHash
import LoggerKit

class CXFNode {

    public enum NodeError: LocalizedError {
        case missingImagePath
        case missingAttribute(String)

        public var errorDescription: String? {
            switch self {
            case .missingImagePath:
                return "Node misses the image path."
            case .missingAttribute(let attributeName):
                return "Node misses the required “\(attributeName)” attribute."
            }
        }
    }

    private let nodeXML: XMLIndexer
    private let collage: CXFCollage

    private let scale: CGFloat
    private let proportionalRect: CGRect

    internal let theta: CGFloat
    internal var collageArea: CGRect

    internal let imageURL: URL

    internal init(element: XMLIndexer, collage: CXFCollage) throws {
        self.nodeXML = element
        self.collage = collage

        guard let imagePath = nodeXML["src"].element?.text else {
            throw NodeError.missingImagePath
        }

        self.imageURL = collage.imageURL(from: imagePath)
        Logger.log(debug: "Loading node “\(imageURL.lastPathComponent)”...")

        guard let xString = nodeXML.element?.attribute(by: "x")?.text, let x = Double(xString) else {
            throw NodeError.missingAttribute("x")
        }

        guard let yString = nodeXML.element?.attribute(by: "y")?.text, let y = Double(yString) else {
            throw NodeError.missingAttribute("x")
        }

        guard let widthString = nodeXML.element?.attribute(by: "w")?.text, let width = Double(widthString) else {
            throw NodeError.missingAttribute("w")
        }

        guard let heightString = nodeXML.element?.attribute(by: "h")?.text, let height = Double(heightString) else {
            throw NodeError.missingAttribute("h")
        }

        self.proportionalRect = CGRect(x: x, y: y, width: width, height: height)
        Logger.log(debug: "Node proportional area: \(self.proportionalRect)")

        guard let thetaString = nodeXML.element?.attribute(by: "theta")?.text, let theta = Double(thetaString) else {
            throw NodeError.missingAttribute("theta")
        }

        self.theta = CGFloat(theta)
        Logger.log(debug: "Node angle: \(self.theta)")

        guard let scaleString = nodeXML.element?.attribute(by: "scale")?.text, let scale = Double(scaleString) else {
            throw NodeError.missingAttribute("scale")
        }

        self.scale = CGFloat(scale)
        Logger.log(debug: "Node scale: \(self.scale)")

        let areaWidth = self.proportionalRect.width * (collage.size.width - collage.spacing) - collage.spacing
        let areaHeight = self.proportionalRect.height * (collage.size.height - collage.spacing) - collage.spacing

        let areaX = self.proportionalRect.origin.x * (collage.size.width - collage.spacing) + collage.spacing
        let areaY = collage.size.height - self.proportionalRect.origin.y * (collage.size.height - collage.spacing) - collage.spacing - areaHeight

        let collageArea = CGRect(x: areaX, y: areaY, width: areaWidth, height: areaHeight)

        Logger.log(debug: "Node collage area: \(collageArea)")
        Logger.log(debug: "Node image path: \(imageURL.lastPathComponent)")

        self.collageArea = collageArea
    }

    internal var topLeftCenteredArea: CGRect {
        return CGRect(x: 0, y: 0, width: self.collageArea.width, height: -self.collageArea.height)
    }

    internal var image: CGImage? {
        Logger.log(debug: "Loading node image \(imageURL.lastPathComponent)...")

        return CGImage.cgImage(url: self.imageURL, ratio: self.collageArea.size.ratio)
    }
}
#endif
