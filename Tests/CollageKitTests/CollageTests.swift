//
//  LottoManagerTests.swift
//  LottoKitTests
//
//  Created by Pedro José Pereira Vieito on 22/11/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import XCTest
import CoreGraphicsKit
@testable import CollageKit

class CollageTests: XCTestCase {
    static let testBundle = Bundle.currentModuleBundle()
    static let testCollageURL = CollageTests.testBundle.url(forResource: "TestCollage", withExtension: "cxf")!
    
    func testCollage() throws {
        let collage = try Collage(contentsOf: CollageTests.testCollageURL)
        XCTAssertEqual(collage.albumTitle, "TEST_COLLAGE")
        XCTAssertEqual(collage.albumDate, "1993-03-20")
        XCTAssertEqual(
            collage.imagesDirectoryURL?.resolvingSymlinksInPath(),
            FileManager.default.homeDirectoryForCurrentUser.resolvingSymlinksInPath())
        XCTAssertEqual(collage.name, "TestCollage")
        
        XCTAssertEqual(collage.collageRatio, 297 / 210)
        XCTAssertEqual(collage.spacing, 0.245016)
        XCTAssertEqual(collage.shadows, true)
        XCTAssertEqual(collage.nodes.count, 3)
        
        XCTAssertEqual(collage.nodes[0].theta, 0.1)
        XCTAssertEqual(collage.nodes[0].area.ratio, 1.06, accuracy: 0.1)
        XCTAssertEqual(collage.collageImageURL(for: collage.nodes[0].src).lastPathComponent, "SeaPhoto.png")
        XCTAssertEqual(collage.nodes[1].theta, 0)
        XCTAssertEqual(collage.collageImageURL(for: collage.nodes[1].src).lastPathComponent, "MakePass.png")
        XCTAssertEqual(
            collage.collageImageURL(for: collage.nodes[1].src).resolvingSymlinksInPath(),
            CollageTests.testCollageURL.deletingLastPathComponent().appendingPathComponent("MakePass.png").resolvingSymlinksInPath())
        XCTAssertEqual(collage.nodes[2].theta, 0)
        XCTAssertEqual(collage.collageImageURL(for: collage.nodes[2].src).lastPathComponent, "__FAKE__.jpg")
        XCTAssertEqual(
            collage.collageImageURL(for: collage.nodes[2].src).resolvingSymlinksInPath(),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("__FAKE__.jpg").resolvingSymlinksInPath())
        
        #if canImport(CoreGraphics)
        let image = try collage.render(for: 2048)
        
        #if Xcode
        try image.open()
        #endif
        #endif
    }
}
