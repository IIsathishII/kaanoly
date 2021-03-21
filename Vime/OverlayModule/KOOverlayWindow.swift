//
//  KOOverlayWindow.swift
//  Kaanoly
//
//  Created by SathishKumar on 31/05/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOOverlayWindow : NSWindow {

    var overlayViewController : KOOverlayViewController
    
    init() {
        overlayViewController = KOOverlayViewController.init()
        let screenFrame = NSScreen.screens[0].frame ?? NSRect.zero
        super.init(contentRect: NSRect.init(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height), styleMask: [.borderless], backing: .buffered, defer: false)
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor.clear
        self.ignoresMouseEvents = true
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.overlayViewController.setup(propertiesManager: propertiesManager)
        self.contentViewController = overlayViewController
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
    }
    
    override func resignKey() {
        super.resignKey()
    }
    
    override func resignMain() {
        super.resignMain()
    }
}
