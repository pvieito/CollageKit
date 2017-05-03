//
//  CGSize.swift
//  CollageTool
//
//  Created by Pedro José Pereira Vieito on 26/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension CGSize: CustomStringConvertible {

    public var description: String {
        return "\(Int(self.width)) × \(Int(self.height))"
    }

    internal init(ratio: CGFloat, width: CGFloat) {
        self.init(width: width, height: width / ratio)
    }

    internal func scaled(by factor: CGFloat) -> CGSize {
        return CGSize(width: CGFloat(self.width) * factor, height: CGFloat(self.height) * factor)
    }

    internal var ratio: CGFloat {
        return CGFloat(self.width / self.height)
    }
}