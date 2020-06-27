//
//  KOWindowsCoordinator.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOWindowsCoordinator {
    
    var statusItem: NSStatusItem
    var menu: NSMenu
    var overlayWindow: KOOverlayWindow?
    var homeWindow: KOHomeWindow?
    var items: [NSStatusItem]
    
    init() {
        menu = NSMenu.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Kaanoly"
        items = []
        self.setUpMenu()
    }
    
    func setUpMenu() {
        let recordItem = NSMenuItem.init(title: "Open Recording", action: #selector(openHome), keyEquivalent: "r")
        recordItem.target = self
        menu.addItem(recordItem)
        self.statusItem.menu = menu
    }
    
    @objc func openHome() {
        if homeWindow == nil {
            KORecordingCoordinator.sharedInstance.setupRecorder(mediaSource: [.screen, .camera, .audio])
            
            overlayWindow = KOOverlayWindow.init(mediaSource: [.screen, .camera, .audio])
            overlayWindow?.level = .screenSaver
            overlayWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .transient]
            overlayWindow?.orderFrontRegardless()
            
            homeWindow = KOHomeWindow.init()
            homeWindow?.homeViewController.delegate = self
            homeWindow?.level = .floating
            homeWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .transient]
            homeWindow?.orderFrontRegardless()
        }
    }
    
    deinit {
        
    }
}

extension KOWindowsCoordinator : KOWindowsCoordinatorDelegate {
    
    func change(Source source: KOMediaSettings.MediaSource) {
        KORecordingCoordinator.sharedInstance.modifyRecorder(mediaSource: source)
        self.overlayWindow?.setSource(source)
        self.overlayWindow?.setupSource()
    }
}
