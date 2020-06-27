//
//  KOColorProperties.swift
//  Kaanoly
//
//  Created by SathishKumar on 13/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation
import AppKit

class KOColorProperties {
    
    static let sharedInstance = KOColorProperties.init()
    
    private init() {}
    
    var cameraPreviewBorderColor : NSColor = NSColor.yellow
}
