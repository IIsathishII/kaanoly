//
//  KOHomeDropDownButton.swift
//  Kaanoly
//
//  Created by SathishKumar on 13/12/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOHomeDropDownButton : NSButton {
    
    override var title: String {
        didSet {
            self.attributedTitle = NSAttributedString.init(string: self.title, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: NSColor.white])
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.alphaValue = 1.0
            } else {
                self.alphaValue = 0.6
            }
        }
    }
    
    var trackingArea : NSTrackingArea!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.bezelStyle = .texturedSquare
        self.isBordered = false
        self.wantsLayer = true
        self.focusRingType = .none
        self.layer?.cornerRadius = 4
        self.layer?.borderWidth = 0.5
        self.layer?.borderColor = NSColor.white.cgColor
        self.target = self
        self.action = #selector(buttonPressed)
        self.image = NSImage.init(named: "Drop_down_arrow")
        self.setTrackingArea()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.init(red: 26/255, green: 26/255, blue: 26/255, alpha: 1).setFill()
        dirtyRect.fill()
        let origin = self.bounds.insetBy(dx: 12, dy: 7).origin
        self.attributedTitle.draw(in: NSRect.init(origin: origin, size: NSSize.init(width: self.attributedTitle.size().width, height: 16)))
        self.image?.draw(in: NSRect.init(origin: NSPoint.init(x: self.frame.width-self.image!.size.width-8, y: 12), size: NSSize.init(width: 10, height: 6)))
    }
    
    override func layout() {
        super.layout()
        self.menu?.minimumWidth = self.frame.size.width
    }
    
    @objc func buttonPressed() {
        self.menu?.popUp(positioning: nil, at: NSPoint.init(x: 0, y: self.frame.size.height), in: self)
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
        if !self.isEnabled {
            NSCursor.operationNotAllowed.set()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.arrow.set()
    }
}
