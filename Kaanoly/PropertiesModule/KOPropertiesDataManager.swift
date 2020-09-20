//
//  KOPropertiesDataSource.swift
//  Kaanoly
//
//  Created by SathishKumar on 13/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

protocol KOPropertiesDataManager : class {
    
    var viewDelegate: KOWindowsCoordinatorDelegate? { get set }
    
    func getSource() -> KOMediaSettings.MediaSource
    func setSource(_ source: KOMediaSettings.MediaSource)
    
    func getCurrentScreen() -> NSScreen
    func setCurrentScreen(_ screen: NSScreen)
    func getCurrentScreenFrame() -> NSRect
}
