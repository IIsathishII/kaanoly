//
//  KOCameraPreviewMovableView.swift
//  Kaanoly
//
//  Created by SathishKumar on 14/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOCameraPreviewMovableView : NSFlippedView {
    
    weak var presenterDelegate : KOCameraPreviewPresenterDelegate?
    
    var cursorPos : CameraPreviewConstants.CursorPosition? = nil
    
    init() {
        super.init(frame: .zero)
        self.setResizeTrackingArea()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setResizeTrackingArea() {
        let trackingArea = NSTrackingArea.init(rect: self.bounds, options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.presenterDelegate?.setDiff(self.convert(event.locationInWindow, from: nil))
        self.presenterDelegate?.setHoldLoc(X: nil)
        self.presenterDelegate?.setHoldLoc(Y: nil)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.presenterDelegate?.setDiff(nil)
        self.presenterDelegate?.setHoldLoc(X: nil)
        self.presenterDelegate?.setHoldLoc(Y: nil)
        self.setResizeCursor(pos: nil)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        if self.presenterDelegate?.getCanResize() == true {
            self.presenterDelegate?.setIsResizing(true)
            self.handleResize(Event: event)
        } else {
            self.handleDrag(Event: event)
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        let cornerSpacing = CGFloat(10)
        let lateralSpacing = CGFloat(5)
        let loc = self.convert(event.locationInWindow, from: nil)
        if ((loc.y >= self.frame.origin.y && loc.y <= self.frame.origin.y + cornerSpacing) && (loc.x >= self.frame.origin.x && loc.x <= self.frame.origin.x + cornerSpacing)) {
            self.setResizeCursor(pos: .topleft)
        } else if ((loc.y <= self.frame.origin.y + self.frame.height &&  loc.y >= self.frame.origin.y + self.frame.height - cornerSpacing) && (loc.x <= self.frame.origin.x + self.frame.width && loc.x >= self.frame.origin.x + self.frame.width - cornerSpacing)) {
            self.setResizeCursor(pos: .bottomright)
        } else if ((loc.y >= self.frame.origin.y && loc.y <= self.frame.origin.y + cornerSpacing) && (loc.x <= self.frame.origin.x + self.frame.width && loc.x >= self.frame.origin.x + self.frame.width - cornerSpacing)) {
            self.setResizeCursor(pos: .topright)
        } else if ((loc.y <= self.frame.origin.y + self.frame.height &&  loc.y >= self.frame.origin.y + self.frame.height - cornerSpacing) && (loc.x >= self.frame.origin.x && loc.x <= self.frame.origin.x + cornerSpacing)) {
            self.setResizeCursor(pos: .bottomleft)
        } else if (loc.y >= self.frame.origin.y && loc.y <= self.frame.origin.y + lateralSpacing) {
//            self.setResizeCursor(pos: .top)
        } else if (loc.y <= self.frame.origin.y + self.frame.height &&  loc.y >= self.frame.origin.y + self.frame.height - lateralSpacing) {
//            self.setResizeCursor(pos: .bottom)
        } else if (loc.x >= self.frame.origin.x && loc.x <= self.frame.origin.x + lateralSpacing) {
//            self.setResizeCursor(pos: .left)
        } else if (loc.x <= self.frame.origin.x + self.frame.width && loc.x >= self.frame.origin.x + self.frame.width - lateralSpacing) {
//            self.setResizeCursor(pos: .right)
        } else {
            self.setResizeCursor(pos: nil)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSCursor.arrow.set()
        self.window?.ignoresMouseEvents = false
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        if self.presenterDelegate?.getIsResizing() == false {
            self.setResizeCursor(pos: nil)
        }
        self.window?.ignoresMouseEvents = true
    }
    
    func setResizeCursor(pos: CameraPreviewConstants.CursorPosition?) {
        if pos != nil {
            self.cursorPos = pos!
            var cursorImage : NSImage!
            if pos! == .top || pos! == .bottom {
                cursorImage = NSImage.init(named: "resizeVertical")!
            } else if pos! == .left || pos! == .right {
                cursorImage = NSImage.init(named: "resizeHorizontal")!
            } else if pos! == .topleft || pos! == .bottomright {
                cursorImage = NSImage.init(named: "resizeDiagonal120Deg")!
            } else if pos! == .topright || pos! == .bottomleft {
                cursorImage = NSImage.init(named: "resizeDiagonal60Deg")!
            }
            NSCursor.init(image: cursorImage, hotSpot: NSPoint.init(x: cursorImage.size.width/2, y: cursorImage.size.height/2)).set()
            self.presenterDelegate?.setCanResize(true)
        } else {
            NSCursor.arrow.set()
            self.presenterDelegate?.setCanResize(false)
            self.presenterDelegate?.setIsResizing(false)
        }
    }
}
