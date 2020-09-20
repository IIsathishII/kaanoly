//
//  KOPropertiesStore.swift
//  Kaanoly
//
//  Created by SathishKumar on 13/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOPropertiesStore {
    
    weak var viewDelegate: KOWindowsCoordinatorDelegate?
    
    private var source : KOMediaSettings.MediaSource = UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.source) as? KOMediaSettings.MediaSource ?? [.camera, .screen, .audio]
    private var screen : NSScreen = NSScreen.screens[0]
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
    
    func getCurrentScreen() -> NSScreen {
        return screen
    }
    
    func setCurrentScreen(_ screen: NSScreen) {
        self.screen = screen
        self.viewDelegate?.change(Screen: screen)
    }
    
    func getCurrentScreenFrame() -> NSRect {
        return screen.frame
    }
}
