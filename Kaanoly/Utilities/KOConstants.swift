//
//  KOConstants.swift
//  Kaanoly
//
//  Created by SathishKumar on 20/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation

struct CameraPreviewConstants {
    
    enum Size {
        static var defaultScale : CGFloat = 1/4
        static var minScale : CGFloat = 1/6
        static var maxScale : CGFloat = 2/5
    }
    
    static var horizontalSpacing : CGFloat = 36
    static var verticalSpacing : CGFloat = 24
    
    enum CursorPosition {
        case top
        case bottom
        case left
        case right
        case topleft
        case topright
        case bottomleft
        case bottomright
    }
}
