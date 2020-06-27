//
//  KOCameraPreviewMovableView.swift
//  Kaanoly
//
//  Created by SathishKumar on 14/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOCameraPreviewMovableView : NSView {
    
    var delegate : KOCameraPreviewDelegate?
    var diff : NSPoint?
    var holdLocX : CGFloat?
    var holdLocY : CGFloat?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.diff = self.convert(event.locationInWindow, from: nil)
        self.holdLocX = nil
        self.holdLocY = nil
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.diff = nil
        self.holdLocX = nil
        self.holdLocY = nil
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        let viewRect = self.convert(self.frame, to: self.window?.contentView)
        var delX: CGFloat = 0, delY: CGFloat = 0
        if holdLocX == nil {
            if viewRect.origin.x + event.deltaX >= 24 && viewRect.origin.x + event.deltaX + viewRect.width <= screenFrame.width-24 {
                delX = event.deltaX
            } else {
                if event.deltaX < 0, abs(viewRect.origin.x - 24) > 0 {
                    delX =  24 - viewRect.origin.x
                } else if event.deltaX > 0, abs(screenFrame.width - 24 - viewRect.origin.x - viewRect.width) > 0 {
                    delX = screenFrame.width - 24 - viewRect.origin.x - viewRect.width
                }
                self.holdLocX = diff?.x
            }
        } else {
            let loc = self.convert(event.locationInWindow, from: nil)
            if (viewRect.origin.x == 24 && loc.x >= diff!.x) || (viewRect.origin.x+24+viewRect.width == screenFrame.width && loc.x <= diff!.x) {
                self.holdLocX = nil
            }
            print("$$$$$$$$$$", self.convert(event.locationInWindow, from: nil))
        }
        if holdLocY == nil {
            if viewRect.origin.y + event.deltaY >= 24 && viewRect.origin.y + event.deltaY + viewRect.height <= screenFrame.height-24 {
                delY = event.deltaY
            } else {
                if event.deltaY < 0, viewRect.origin.y - 24 > 0 {
                    delY = 24 - viewRect.origin.y
                } else if event.deltaY > 0, screenFrame.height - 24 - viewRect.origin.y - viewRect.height > 0 {
                    delY = screenFrame.height - 24 - viewRect.origin.y - viewRect.height
                }
                self.holdLocY = diff?.y
            }
        } else {
            let loc = self.convert(event.locationInWindow, from: nil)
            if (viewRect.origin.y == 24 && loc.y <= diff!.y) || (viewRect.origin.y+24+viewRect.height == screenFrame.height && loc.y >= diff!.y) {
                self.holdLocY = nil
            }
        }
        self.delegate?.moveCameraPreview(locX: viewRect.origin.x+delX, locY: viewRect.origin.y+delY)
    }

}
