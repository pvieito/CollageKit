//
//  Collage+CoreGraphics.swift
//  CollageKit
//
//  Created by Pedro José Pereira Vieito on 23/11/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(CoreGraphics)
import Foundation
import FoundationKit
import CoreGraphics
import CoreGraphicsKit

extension Collage {
    public func render(for width: Double? = nil) throws -> CGImage {
        let width = width ?? Collage.defaultRenderWidth
        var collageSize = CGSize(ratio: self.collageRatio, width: CGFloat(width))
        collageSize = self.collageDescription.orientation.size(for: collageSize)
        let collageRect = CGRect(origin: CGPoint.zero, size: collageSize)

        guard let context = CGContext(
            data: nil, width: Int(collageSize.width), height: Int(collageSize.height),
            bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                throw Error.genericRenderingError
        }

        if let backgroundColorString = self.collageDescription.background?.color,
            let backgroundColor = CGColor.cgColor(hexARGB: backgroundColorString) {
            context.setFillColor(backgroundColor)
            context.fill(collageRect)
        }

        if let backgroundImageString = self.collageDescription.background?.src,
            let backgroundImage = CGImage.cgImage(
                url: self.collageImageURL(for: backgroundImageString), ratio: collageSize.ratio) {
            context.draw(backgroundImage, in: collageRect)
        }

        for node in self.nodes {
            let nodeArea = self.nodeArea(node: node, collageSize: collageSize, spacing: self.spacing)
            let topLeftCenteredArea = CGRect(x: 0, y: 0, width: nodeArea.width, height: -nodeArea.height)

            context.saveGState()
            context.translateBy(x: nodeArea.minX, y: nodeArea.maxY)
            context.rotate(by: -CGFloat(node.theta))

            if self.shadows {
                context.setShadow(offset: CGSize.zero, blur: collageSize.width * 0.01)
            }
            
            if let nodeImage = CGImage.cgImage(
                url: self.collageImageURL(for: node.src), ratio: nodeArea.ratio) {
                context.draw(nodeImage, in: topLeftCenteredArea)
            }
            else {
                context.setStrokeColor(CGColor.black)
                context.stroke(topLeftCenteredArea, width: 3)
            }

            context.restoreGState()
        }


        guard let renderedImage = context.makeImage() else {
            throw Error.genericRenderingError
        }

        return renderedImage
    }
}
#endif
