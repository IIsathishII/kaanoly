//
//  KOPropertiesStore.swift
//  Kaanoly
//
//  Created by SathishKumar on 13/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOPropertiesStore : NSObject {
    
    weak var viewDelegate: KOWindowsCoordinatorDelegate?

    private var source : KOMediaSettings.MediaSource = UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.source) as? KOMediaSettings.MediaSource ?? [.camera, .screen, .audio]
    private weak var screen : NSScreen? = NSScreen.screens[0]
    private var captureMouseClick = false
    private var isMirrored = true
}

extension KOPropertiesStore : KOPropertiesDataManager {
    
    func getSource() -> KOMediaSettings.MediaSource {
        return source
    }
    
    func setSource(_ source: KOMediaSettings.MediaSource) {
        self.source = source
        KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
        self.viewDelegate?.change(Source: source)
    }
    
    func getCurrentScreen() -> NSScreen? {
        return screen
    }
    
    func setCurrentScreen(_ screen: NSScreen) {
        self.screen = screen
        KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
        self.viewDelegate?.change(Screen: screen)
    }
    
    func getCurrentScreenFrame() -> NSRect? {
        return screen?.frame
    }
    
    func shouldCaptureMouseClick() -> Bool {
        return self.captureMouseClick
    }
    
    func setCaptureMouseClick(_ val: Bool) {
        self.captureMouseClick = val
        KORecordingCoordinator.sharedInstance.setSession(Props: [.mouseHighlighter])
    }
    
    func getIsMirrored() -> Bool {
        return self.isMirrored
    }
    
    func setIsMirrored(_ val: Bool) {
        self.isMirrored = val
        KORecordingCoordinator.sharedInstance.setSession(Props: [.mirrored])
    }
}
