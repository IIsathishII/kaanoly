//
//  KOCircularImageButton.swift
//  Kaanoly
//
//  Created by SathishKumar on 08/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOCircularImageButton : NSButton {
    
    init() {
        super.init(frame: .zero)
        self.wantsLayer = true
        self.focusRingType = .none
        self.imagePosition = .imageOnly
        self.image = NSImage.init(named: "Part_of_screen_accept")!
        self.isBordered = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let newRect = NSRect.init(x: dirtyRect.origin.x+2, y: dirtyRect.origin.y+2, width: dirtyRect.width-4, height: dirtyRect.height-4)
        self.image?.draw(in: newRect)
    }
}
