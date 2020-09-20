//
//  KOHomeWindow.swift
//  Kaanoly
//
//  Created by SathishKumar on 31/05/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOHomeWindow : NSWindow {
    
    var homeViewController = KOHomeViewController.init()
    
    init() {
        super.init(contentRect: NSRect.init(origin: .zero, size: CGSize.init(width: 400, height: 300)), styleMask: [.closable, .titled], backing: .buffered, defer: false)
        self.title = "Kaanoly"
        self.contentViewController = homeViewController
        self.center()
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.homeViewController.propertiesManager = propertiesManager
    }
    
    override func close() {
        super.close()
        KORecordingCoordinator.sharedInstance.destroyRecorder()
    }
}
