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
        super.init(contentRect: NSRect.init(origin: .zero, size: CGSize.init(width: 350, height: 450)), styleMask: [.closable, .titled], backing: .buffered, defer: false)
        self.title = "Vime"
        self.contentViewController = homeViewController
        self.center()
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?, coordinatorDelegate: KOWindowsCoordinatorDelegate?) {
        self.homeViewController.propertiesManager = propertiesManager
        self.homeViewController.viewDelegate = coordinatorDelegate
    }
    
    override func close() {
        super.close()
        if !self.homeViewController.isRecording {
            self.handleWindowClose()
        }
    }
    
    func handleWindowClose() {
        self.homeViewController.propertiesManager?.getStorageDirectory()?.stopAccessingSecurityScopedResource()
        KORecordingCoordinator.sharedInstance.destroyRecorder()
    }
}
