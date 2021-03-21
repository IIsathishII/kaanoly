//
//  KOHomeLargeIcon.swift
//  Kaanoly
//
//  Created by SathishKumar on 12/12/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOHomeLargeIcon : NSButton {
    
    var isClickNotAllowed = false {
        didSet {
            self.isEnabled = !self.isClickNotAllowed
        }
    }
    
    var trackingArea : NSTrackingArea!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.imagePosition = .imageOnly
        self.bezelStyle = .texturedSquare
        self.isBordered = false
        self.wantsLayer = true
        self.focusRingType = .none
        self.layer?.cornerRadius = 5
        self.setButtonType(.toggle)
        self.setTrackingArea()
        (self.cell as? NSButtonCell)?.imageDimsWhenDisabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if self.state == .off {
            NSColor.clear.setFill()
            dirtyRect.fill()
        } else {
            NSColor.init(named: "homeIconSelectedColor")!.setFill()
            dirtyRect.fill()
        }
        
        super.draw(dirtyRect)
    }
    
    override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
        self.needsDisplay = true
        return super.sendAction(action, to: target)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.removeTrackingArea(self.trackingArea)
        self.setTrackingArea()
    }
    
    func setTrackingArea() {
        self.trackingArea = NSTrackingArea.init(rect: self.bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        if self.isClickNotAllowed {
            NSCursor.operationNotAllowed.set()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.arrow.set()
    }
}
