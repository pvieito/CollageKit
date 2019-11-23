//
//  Collage.swift
//  CollageKit
//
//  Created by Pedro José Pereira Vieito on 23/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import CoreGraphicsKit
import XMLCoder

public struct Collage {
    struct Structure: Codable {
        struct Background: Codable {
            let color: String?
            let src: String?
        }
        
        struct Spacing: Codable {
            let value: Double
        }
        
        enum Orientation: String, Codable {
            case portrait
            case landscape
        }
        
        let version: String
        let format: String
        let orientation: Orientation
        let theme: String
        let shadows: Bool?
        let spacing: Spacing?
        let background: Background?
        
        let albumTitle: String?
        let albumDate: String?
        let albumUID: String?
        
        let captions: Bool?
        let node: [CollageNode]
    }
    
    internal let collageURL: URL
    internal let collageRatio: CGRatio
    internal let collageDescription: Structure
    
    public var albumTitle: String? {
        return self.collageDescription.albumTitle
    }
    
    public var albumDate: String? {
        return self.collageDescription.albumDate
    }
    
    public var albumIdentifier: String? {
        return self.collageDescription.albumUID
    }
    
    internal var nodes: [CollageNode] {
        return self.collageDescription.node
    }
    
    internal var shadows: Bool {
        return self.collageDescription.shadows ?? false
    }
    
    internal var spacing: Double {
        return self.collageDescription.spacing?.value ?? 0.0
    }
}

extension Collage {
    public init(contentsOf url: URL) throws {
        let collageData = try Data(contentsOf: url)
        let decoder = XMLDecoder()
        self.collageDescription = try! decoder.decode(Structure.self, from: collageData)
        
        guard self.collageDescription.version == "2" else {
            throw Error.decodingFormatError
        }
        
        let formatComponents = self.collageDescription.format.split(separator: ":")
        guard formatComponents.count == 2,
            let formatWidth = Int(formatComponents[0]),
            let formatHeight = Int(formatComponents[1]) else {
            throw Error.decodingFormatError
        }
        
        self.collageRatio = CGSize(width: formatWidth, height: formatHeight).ratio
        self.collageURL = url.resolvingSymlinksInPath()
    }
}

extension Collage {
    public var name: String {
        return self.collageURL.deletingPathExtension().lastPathComponent
    }
    
    public var imagesDirectoryURL: URL? {
        var imageSources = self.nodes.map({ $0.src })
        if let backgroundImageSource = self.collageDescription.background?.src {
            imageSources.append(backgroundImageSource)
        }
        return imageSources.map({ self.collageImageURL(for: $0) }).commonAntecessor
    }
}
    
extension Collage {
    public static let defaultRenderWidth: Double = 2100

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

extension Collage.Structure.Orientation {
    func size(for format: CGSize) -> CGSize {
        switch self {
        case .portrait:
            return format.portrait
        case .landscape:
            return format.landscape
        }
    }
}

extension Collage {
    func collageImageURL(for collagePath: String) -> URL {
        if collagePath.hasPrefix("$"), let userHomeURL = FileManager.default.realHomeDirectoryForCurrentUser {
            let cxfPath = collagePath.applyingRegularExpression(pattern: "^\\$(HomeDir\\/)?", sustitution: "")
            return URL(fileURLWithPath: cxfPath, relativeTo: userHomeURL)
        }
        else {
            return URL(fileURLWithPath: collagePath, relativeTo: self.collageURL)
        }
    }
}

extension Collage {
    func nodeArea(node: CollageNode, collageSize: CGSize, spacing: Double) -> CGRect {
        let spacing = CGFloat(spacing) * (0.09 * collageSize.max)
        let areaWidth = node.area.width * (collageSize.width - spacing) - spacing
        let areaHeight = node.area.height * (collageSize.height - spacing) - spacing
        let areaX = node.area.origin.x * (collageSize.width - spacing) + spacing
        let areaY = collageSize.height - node.area.origin.y * (collageSize.height - spacing) - spacing - areaHeight
        return CGRect(x: areaX, y: areaY, width: areaWidth, height: areaHeight)
    }
}
