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

    public enum CollageError: LocalizedError {
        case versionNotSupported(Int)
        case collageThemeNotSupported(String)
        case missingAttribute(String)
        case malformedAttribute(String)
        case invalidGraphicContext
        case invalidCollageFile

        public var errorDescription: String? {
            switch self {
            case .invalidCollageFile:
                return "Invalid collage file."
            case .versionNotSupported(let version):
                return "Collage file version “\(version)” not suported. Only version 2 is supported."
            case .collageThemeNotSupported(let theme):
                return "Collage theme “\(theme)” not suported."
            case .missingAttribute(let attributeName):
                return "Collage file misses the required “\(attributeName)” attribute."
            case .malformedAttribute(let attributeName):
                return "Collage file has an unkown format for the “\(attributeName)” attribute."
            case .invalidGraphicContext:
                return "Invalid Core Graphics context."
            }
        }
    }

    internal enum Orientation: String {
        case portrait
        case landscape

        func size(for format: CGSize) -> CGSize {

            switch self {
            case .portrait:
                return format.portrait
            case .landscape:
                return format.landscape
            }
        }
    }

    internal enum Theme: String {
        case picturepile
        case framegrid
        case picturegrid
        case regulargrid
        case contactsheet
        case multiexp

        var supported: Bool {
            return ![.picturepile, .multiexp, .contactsheet].contains(self)
        }
    }

    private let collageXML: XMLIndexer
    private let collageURL: URL
    private let context: CGContext
    private let version: Int
    private let shadows: Bool
    private let backgroundColor: CGColor
    private var backgroundImageURL: URL? = nil
    private var nodes: [CXFNode] = []

    internal let orientation: Orientation
    internal let theme: Theme
    internal let spacing: CGFloat

    public var image: CGImage? = nil
    public let width: CGFloat = 2100

    public let albumTitle: String?
    public let albumDate: String?
    public let size: CGSize

    // MARK: Public implementation.

    /// Collage filename.
    public var name: String {
        return collageURL.lastPathComponent
    }

    public convenience init(contentsOf collagePath: String) throws {
        let collageURL = URL(fileURLWithPath: collagePath)
        try self.init(contentsOf: collageURL)
    }

    public init(contentsOf collageURL: URL) throws {
        self.collageURL = collageURL

        Logger.log(debug: "Reading Collage data...")
        let collageData = try Data(contentsOf: collageURL)

        Logger.log(debug: "Parsing XML...")
        self.collageXML = SWXMLHash.parse(collageData)["collage"]


        // Required Attributes

        guard let collageElement = self.collageXML.element else {
            throw CollageError.invalidCollageFile
        }

        guard let versionString = collageElement.attribute(by: "version")?.text, let version = Int(versionString) else {
            throw CollageError.missingAttribute("version")
        }

        Logger.log(debug: "Collage Format Version: \(version)")

        guard version == 2 else {
            throw CollageError.versionNotSupported(version)
        }

        self.version = version

        guard let orientationString = collageElement.attribute(by: "orientation")?.text, let orientation = Orientation(rawValue: orientationString) else {
            throw CollageError.malformedAttribute("orientation")
        }

        self.orientation = orientation
        Logger.log(debug: "Collage Orientation: \(self.orientation)")

        guard let themeString = collageElement.attribute(by: "theme")?.text, let theme = Theme(rawValue: themeString) else {
            throw CollageError.malformedAttribute("theme")
        }

        guard theme.supported else {
            throw CollageError.collageThemeNotSupported(theme.rawValue)
        }

        self.theme = theme
        Logger.log(debug: "Collage Theme: \(self.theme)")

        guard let sizeString = collageElement.attribute(by: "format")?.text.components(separatedBy: ":") else {
            throw CollageError.missingAttribute("format")
        }

        guard let widthString = sizeString.first, let heightString = sizeString.last, let widthInt = Double(widthString), let heightInt = Double(heightString) else {
            throw CollageError.malformedAttribute("format")
        }

        let collageRatio = CGSize(width: widthInt, height: heightInt).ratio
        self.size = orientation.size(for: CGSize(ratio: collageRatio, width: width))

        Logger.log(debug: "Collage Size: \(self.size)")

        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw CollageError.invalidGraphicContext
        }

        self.context = context


        // Optional Attributes

        self.albumTitle = collageXML["albumTitle"].element?.text
        self.albumDate = collageXML["albumDate"].element?.text

        Logger.log(debug: "Collage Name: \(self.albumTitle ?? "--")")
        Logger.log(debug: "Collage Subtitle: \(self.albumDate ?? "--")")

        self.shadows = collageElement.attribute(by: "shadows")?.text == "1"

        Logger.log(debug: "Collage Shadows: \(self.shadows)")

        if let spacingString = collageXML["spacing"].element?.attribute(by: "value")?.text, let spacingInt = Double(spacingString) {
            let spacing = CGFloat(spacingInt)
            self.spacing = (0.09 * self.size.max) * spacing
            Logger.log(debug: "Collage Spacing: \(spacingString) -> \(self.spacing)")
        }
        else {
            self.spacing = 0
            Logger.log(debug: "Collage Spacing: Not specified")
        }

        if let hexColorString = collageXML["background"].element?.attribute(by: "color")?.text, let hexColor = Int(hexColorString, radix: 16) {
            self.backgroundColor = CGColor.init(argb: hexColor)
            Logger.log(debug: "Collage Background Color: \(hexColorString) -> \(self.backgroundColor.components?.debugDescription ?? "--")")
        }
        else {
            self.backgroundColor = CGColor.white
            Logger.log(debug: "Collage Background Color: Not specified")
        }

        if let backgroundImagePath = collageXML["background"]["src"].element?.text {
            let backgroundImageURL = self.imageURL(from: backgroundImagePath)
            self.backgroundImageURL = backgroundImageURL
            Logger.log(debug: "Collage Background: Image: \(backgroundImageURL.lastPathComponent).")
        }
        else {
            Logger.log(debug: "Collage Background: Image: Not specified")
        }

        Logger.log(debug: "Parsing Nodes...")

        for nodeXML in collageXML["node"].all {
            do {
                let node = try CXFNode(element: nodeXML, collage: self)
                nodes.append(node)
            }
            catch {
                Logger.log(warning: error.localizedDescription)
            }
        }

        guard self.nodes.count > 0 else {
            throw CollageError.invalidCollageFile
        }

        Logger.log(debug: "Collage parsed successfully.")
    }

    /// Render the collage an save it in the image property.
    public func render() {
        Logger.log(debug: "Rendering Collage...")

        let collageRect = CGRect(origin: CGPoint.zero, size: self.size)
        self.context.setFillColor(backgroundColor)
        self.context.fill(collageRect)

        if let backgroundImageURL = self.backgroundImageURL, let backgroundImage = CGImage.init(url: backgroundImageURL, croppingRatio: self.size) {
            Logger.log(debug: "Drawing background image: \(backgroundImageURL.path)")

            self.context.draw(backgroundImage, in: collageRect)
        }

        Logger.log(debug: "Filling background color...")

        for node in self.nodes {
            if let image = node.image {
                Logger.log(debug: "Drawing node image: \(node.imageURL.path)")

                self.context.saveGState()
                self.context.translateBy(x: node.collageArea.minX, y: node.collageArea.maxY)
                self.context.rotate(by: -node.theta)

                if self.shadows {
                    self.context.setShadow(offset: CGSize.zero, blur: self.size.width * 0.01)
                }

                self.context.draw(image, in: node.topLeftCenteredArea)
                self.context.restoreGState()
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
        DispatchQueue(label: "com.pvieito.CollageKit.CXFCollage.collageRendering").async {
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
        let nodeImageURLs = self.nodes.map({ $0.imageURL })

        if let backgroundImageURL = self.backgroundImageURL {
            return nodeImageURLs.appending(backgroundImageURL).commonAntecessor
        }

        return nodeImageURLs.commonAntecessor
    }


    // MARK: Private implementation.

    internal func imageURL(from cxfPath: String) -> URL {
        if cxfPath.hasPrefix("$"), let userPath = getpwuid(getuid()).pointee.pw_dir {
            let cxfPath = cxfPath.applyingRegularExpression(pattern: "^\\$(HomeDir\\/)?", sustitution: "")
            
            let userHomeURL = URL(fileURLWithPath: String(cString: userPath))
            return URL(fileURLWithPath: cxfPath, relativeTo: userHomeURL)
        }
        else {
            return URL(fileURLWithPath: cxfPath, relativeTo: self.collageURL)
        }
    }
}
