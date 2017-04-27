//
//  CGImage.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 26/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension CGImage {

    /// Crops the image with the given ratio at the center with the maximum width or height.
    ///
    /// - Parameter ratio: CGSize that specifies the crop ratio. Only the ratio is haved in account, not the size.
    /// - Returns: The cropped are of the image with the specified ratio.
    internal func cropping(ratio: CGSize) -> CGImage? {
        if CGFloat(self.width) / CGFloat(self.height) > ratio.ratio {
            let width = Int(CGFloat(self.height) * ratio.ratio)
            return self.cropping(to: CGRect(x: self.width / 2 - width / 2, y: 0, width: width, height: self.height))
        }
        else {
            let height = Int(CGFloat(self.width) / ratio.ratio)
            return self.cropping(to: CGRect(x: 0, y: self.height / 2 - height / 2, width: self.width, height: height))
        }
    }

    /// Writes image in a destiantion with the specified format.
    ///
    /// - Parameters:
    ///   - url: Destiantion URL.
    ///   - format: Destination format. JPEG by default.
    public func write(at url: URL, format: CFString = kUTTypeJPEG) {

        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, format, 1, nil) else {
            return
        }

        CGImageDestinationAddImage(destination, self, nil)
        CGImageDestinationFinalize(destination)
    }
}
