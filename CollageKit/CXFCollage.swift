//
//  CXFCollage.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 23/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import CoreGraphics
import SWXMLHash
import LoggerKit
import FoundationKit

public class CXFCollage {

    private let collageXML: XMLIndexer
    private let context: CGContext
    private let backgroundColor: CGColor

    internal let collageURL: URL
    internal let spacing: CGFloat

    public var image: CGImage? = nil
    public let width: CGFloat = 2100

    public let albumTitle: String
    public let albumDate: String
    public let size: CGSize


    // MARK: Public implementation.

    /// Collage filename.
    public var name: String {
        return collageURL.lastPathComponent
    }

    public convenience init?(contentsOf collagePath: String) {
        let collageURL = URL(fileURLWithPath: collagePath)
        self.init(contentsOf: collageURL)
    }

    public init?(contentsOf collageURL: URL) {
        self.collageURL = collageURL

        guard let collageData = try? Data(contentsOf: collageURL) else {
            return nil
        }

        collageXML = SWXMLHash.parse(collageData)["collage"]

        guard let albumTitle = collageXML["albumTitle"].element?.text else {
            return nil
        }

        self.albumTitle = albumTitle

        guard let albumDate = collageXML["albumDate"].element?.text else {
            return nil
        }

        self.albumDate = albumDate

        guard let sizeString = collageXML.element?.attribute(by: "format")?.text.components(separatedBy: ":") else {
            return nil
        }

        guard let widthString = sizeString.first, let heightString = sizeString.last, let widthInt = Double(widthString), let heightInt = Double(heightString) else {
            return nil
        }

        let collageRatio = CGSize(width: widthInt, height: heightInt).ratio
        self.size = CGSize(ratio: collageRatio, width: width)

        guard let hexColorString = collageXML["background"].element?.attribute(by: "color")?.text, let hexColor = Int(hexColorString, radix: 16) else {
            return nil
        }

        self.backgroundColor = CGColor.init(rgba: hexColor)

        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }

        self.context = context

        guard let spacingString = collageXML["spacing"].element?.attribute(by: "value")?.text, let spacingInt = Double(spacingString) else {
            return nil
        }

        let spacing = CGFloat(spacingInt)
        self.spacing = (0.0978 * pow(spacing, 2) - 0.0145 * spacing + 0.0157) * self.size.width
    }

    /// Render the collage an save it in the image property.
    public func render() {
        Logger.log(debug: "Rendering Collage...")

        self.context.setFillColor(backgroundColor)
        self.context.fill(CGRect(origin: CGPoint.zero, size: self.size))

        Logger.log(debug: "Filling background color: \(self.backgroundColor.components ?? [])")

        for node in self.nodes {
            if let image = node.image {
                Logger.log(debug: "Drawing node image: \(node.imageURL.path)")
                self.context.draw(image, in: node.collageArea)
            }
            else {
                Logger.log(debug: "Drawing node black area: \(node.imageURL.path)")
                self.context.setStrokeColor(CGColor.black)
                self.context.stroke(node.collageArea, width: 3)
            }
        }

        self.image = self.context.makeImage()
        Logger.log(debug: "Collage finished rendering.")
    }

    /// Render asynchronously the collage.
    ///
    /// - Parameter completionHandler: Called when the rendering has finished.
    public func render(completionHandler: @escaping (CGImage?) -> ()) {
        DispatchQueue(label: "com.pvieito.CXFCollage").async {
            self.render()

            DispatchQueue.main.async {
                completionHandler(self.image)
            }
        }
    }

    /// Saves the rendered image to a temporary path.
    public func saveImageTemporary() -> URL? {

        guard let image = self.image else {
            Logger.log(error: "No image rendered. Cannot save temporary image.")
            return nil
        }

        let bundleIdentifier = Bundle.init(for: CXFCollage.self).bundleIdentifier ?? "CollageKit"

        let temporalDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(bundleIdentifier).appendingPathComponent("CXFCollage")

        try? FileManager.default.removeItem(at: temporalDirectoryURL)

        do {
            try FileManager.default.createDirectory(at: temporalDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            let temporaryImageURL = temporalDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            image.write(at: temporaryImageURL)

            Logger.log(debug: "Temporary image saved at: \(temporaryImageURL.path)")
            return temporaryImageURL
        }
        catch {
            Logger.log(error: "Error saving temporary image: \(error.localizedDescription).")
            return nil
        }
    }

    /// Sandboxed apps should have access to this path to compose the collage successfully.
    public var imagesDirectoryURL: URL? {
        return self.nodes.map({ $0.imageURL }).commonAntecessor
    }
    

    // MARK: Private implementation.

    private var nodes: [CXFNode] {
        return collageXML["node"].all.map({ CXFNode(element: $0, collage: self) }).filter({ $0 != nil }) as? [CXFNode] ?? []
    }
}
