//
//  KOPropertiesDataSource.swift
//  Kaanoly
//
//  Created by SathishKumar on 13/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import AVFoundation

protocol KOPropertiesDataManager : class {
    
    var viewDelegate: KOWindowsCoordinatorDelegate? { get set }
    
    func getStorageDirectory() -> URL?
    func setStorageDirectory(_ val: URL?)
    
    func getIsCloudDirectory() -> Bool
    func setIsCloudDirectory(_ val: Bool)
    
    func getSource() -> KOMediaSettings.MediaSource
    func setSource(_ source: KOMediaSettings.MediaSource)
    
    func getCurrentScreen() -> NSScreen?
    func setCurrentScreen(_ screen: NSScreen)
    func getCurrentScreenFrame() -> NSRect?
    
    func setCurrentAudio(Source source: AVCaptureDevice)
    func setCurrentVideo(Source source: AVCaptureDevice)
    
    func shouldCaptureMouseClick() -> Bool
    func setCaptureMouseClick(_ val: Bool)
    
    func getIsMirrored() -> Bool
    func setIsMirrored(_ val: Bool)
    
    func bookmarkRecording(Path path: URL)
    func getRecentVideos() -> [URL]
    
    func setCropped(Rect rect: NSRect?, displayId: CGDirectDisplayID)
    func getCroppedRect() -> NSRect?
    func isRecordingPartOfWindow() -> Bool
    
    func resetProperties()
}
