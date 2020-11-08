//
//  KOPartOfScreenPickerWindow.swift
//  Kaanoly
//
//  Created by SathishKumar on 07/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOPartOfScreenPickerWindow : NSWindow {
    
    var pickerViewController : KOPartOfScreenPickerViewController
    var displayId : CGDirectDisplayID
    
    init(displayId: CGDirectDisplayID) {
        self.displayId = displayId
        self.pickerViewController = KOPartOfScreenPickerViewController.init()
        super.init(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        self.contentViewController = self.pickerViewController
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor.clear
        self.isOpaque = true
        self.ignoresMouseEvents = false
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.pickerViewController.setup(propertiesManager: propertiesManager)
    }
    
    override func cancelOperation(_ sender: Any?) {
        self.pickerViewController.propertiesManager?.setCropped(Rect: nil, displayId: self.displayId)
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    deinit {
        print("Picker window deinit")
    }
}
