//
//  KOCircularImageButton.swift
//  Kaanoly
//
//  Created by SathishKumar on 08/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOCircularImageButton : NSButton {
    
    var color : NSColor
    
    init(color: NSColor, image: NSImage) {
        self.color = color
        super.init(frame: .zero)
        self.wantsLayer = true
        self.focusRingType = .none
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath.init(ovalIn: dirtyRect)
        self.color.setFill()
        path.fill()
        
        self.image?.draw(in: dirtyRect)
    }
}
