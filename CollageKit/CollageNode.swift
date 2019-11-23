//
//  CollageNode.swift
//  CollageKit
//
//  Created by Pedro José Pereira Vieito on 23/4/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

struct CollageNode: Codable {
    private let x: Double
    private let y: Double
    private let w: Double
    private let h: Double
    
    let theta: Double
    let scale: Double
    
    let src: String
    let uid: String?
    let theme: String?
}

extension CollageNode {
    var area: CGRect {
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
