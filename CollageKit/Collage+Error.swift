//
//  URL+Collage.swift
//  CollageKit
//
//  Created by Pedro José Pereira Vieito on 23/11/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Collage {
    public enum Error: LocalizedError {
        case genericRenderingError
        case decodingFormatError

        public var errorDescription: String? {
            switch self {
            case .genericRenderingError:
                return "Error rendering collage image."
            case .decodingFormatError:
                return "Error decoding collage format."
            }
        }
    }
}
