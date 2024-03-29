//
//  KOPropertiesStore.swift
//  Kaanoly
//
//  Created by SathishKumar on 13/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import AVFoundation

class KOPropertiesStore : NSObject {
    
    weak var viewDelegate: KOWindowsCoordinatorDelegate?

    private var source : KOMediaSettings.MediaSource = {
        var defaultSource : KOMediaSettings.MediaSource = UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.source) as? KOMediaSettings.MediaSource ?? [.camera, .screen, .audio]
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            defaultSource.remove(.camera)
        }
        if AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
            defaultSource.remove(.audio)
        }
        if !CGRequestScreenCaptureAccess() {
            defaultSource.remove(.screen)
        }
        return defaultSource
    }()
    private var screenId : CGDirectDisplayID? = NSScreen.screens[0].getScreenNumber()
    private var captureMouseClick = (UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.captureMouseClick) as? Bool) ?? false
    private var isMirrored = (UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.mirrorCamera) as? Bool) ?? true
    private var storageDirectory : URL? {
        get {
            var isStale = false
            if let storedValData = UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.storageDirectory) as? Data, let storedVal = try? URL.init(resolvingBookmarkData: storedValData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
                var isDir: ObjCBool = false
                if isStale {
                    return nil
                }
                //TODO:: Handle security scope access start and stop
                if FileManager.default.fileExists(atPath: storedVal.relativePath, isDirectory: &isDir) {
                    if isDir.boolValue {
                        return storedVal
                    }
                }
            }
            return nil
        }
        set {
            
        }
    }
    private var croppedRect : NSRect?
    
    private var recentVideos : [URL] {
        get {
            var recentVideos = [URL]()
            if let storedRecentVideos = UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.recentVideos) as? [Data] {
                let recentVideoUrls = storedRecentVideos.compactMap { (video) -> URL? in
                    var isStale = false
                    //TODO:: Remove stale urls : Deleted or moved
                    if let videoUrl = try? URL.init(resolvingBookmarkData: video, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
                        if !isStale {
                            return videoUrl
                        } else {
//                            self.getStorageDirectory()?.startAccessingSecurityScopedResource()
                            if let data = try? videoUrl.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
                                var newIsStale = false
                                if let newUrl = try? URL.init(resolvingBookmarkData: data, bookmarkDataIsStale: &newIsStale) {
                                    videoUrl.stopAccessingSecurityScopedResource()
                                    return newUrl
                                } else {
                                    
                                }
                            }
                        }
                    }
                    return nil
                }
                recentVideos = recentVideoUrls
            }
            return recentVideos
        }
        set {
            self.recentVideos = newValue
        }
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenChange(_:)), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
    
    @objc func handleScreenChange(_ notification: Notification) {
        if !NSScreen.screens.contains(where: { $0.getScreenNumber() == self.screenId }) && self.getSource().contains(.screen) {
            let screen = NSScreen.screens[0]
            self.screenId = screen.getScreenNumber()
            self.viewDelegate?.stopRecordingAbruptly()
        }
    }
    
    func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: KOUserDefaultKeyConstants.storageDirectory)
        UserDefaults.standard.synchronize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSApplication.didChangeScreenParametersNotification, object: nil)
        self.storageDirectory?.stopAccessingSecurityScopedResource()
    }
}

extension KOPropertiesStore : KOPropertiesDataManager {
    
    func getStorageDirectory() -> URL? {
        return self.storageDirectory
    }
    
    func setStorageDirectory(_ val: URL?) {
//        self.storageDirectory?.stopAccessingSecurityScopedResource()
        self.storageDirectory = val
        if val == nil {
            UserDefaults.standard.removeObject(forKey: KOUserDefaultKeyConstants.storageDirectory)
            return
        }
        if let data = try? val!.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            UserDefaults.standard.setValue(data, forKey: KOUserDefaultKeyConstants.storageDirectory)
            KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
            self.clearAllBookmarks()
//            val.startAccessingSecurityScopedResource()
        } else {
            //TODO:: Error handling.
        }
    }
    
    func getSource() -> KOMediaSettings.MediaSource {
        return source
    }
    
    func setSource(_ source: KOMediaSettings.MediaSource) {
        self.source = source
        KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
        self.viewDelegate?.change(Source: source)
    }
    
    func getCurrentScreen() -> NSScreen? {
        return NSScreen.screens.first(where: { $0.getScreenNumber() == self.screenId })
    }
    
    func setCurrentScreen(_ screen: NSScreen) {
        self.screenId = screen.getScreenNumber()
        KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
        self.viewDelegate?.change(Screen: screen)
    }
    
    func getCurrentScreenFrame() -> NSRect? {
        if self.croppedRect == nil {
            return self.getCurrentScreen()?.frame
        } else {
            if self.croppedRect != nil {
                var finalRect = self.croppedRect!
                finalRect.origin.x += self.getCurrentScreen()?.frame.origin.x ?? 0
                finalRect.origin.y += self.getCurrentScreen()?.frame.origin.y ?? 0
                return finalRect
            }
            return nil
        }
    }
    
    func setCurrentAudio(Source source: AVCaptureDevice) {
        KORecordingCoordinator.sharedInstance.setAudio(Source: source)
        KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
    }
    
    func setCurrentVideo(Source source: AVCaptureDevice) {
        KORecordingCoordinator.sharedInstance.setVideo(Source: source)
        KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
    }
    
    func shouldCaptureMouseClick() -> Bool {
        return self.captureMouseClick
    }
    
    func setCaptureMouseClick(_ val: Bool) {
        self.captureMouseClick = val
        UserDefaults.standard.setValue(val, forKey: KOUserDefaultKeyConstants.captureMouseClick)
        KORecordingCoordinator.sharedInstance.setSession(Props: [.mouseHighlighter])
    }
    
    func getIsMirrored() -> Bool {
        return self.isMirrored
    }
    
    func setIsMirrored(_ val: Bool) {
        self.isMirrored = val
        UserDefaults.standard.setValue(val, forKey: KOUserDefaultKeyConstants.mirrorCamera)
        KORecordingCoordinator.sharedInstance.setSession(Props: [.mirrored])
    }
    
    func bookmarkRecording(Path path: URL) {
        if let data = try? path.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            var recentVideos = [Data]()
            if var storedRecentVideos = UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.recentVideos) as? [Data] {
                if storedRecentVideos.count == 4 {
                    storedRecentVideos.removeLast()
                }
                recentVideos = storedRecentVideos
            }
            recentVideos.insert(data, at: 0)
            UserDefaults.standard.setValue(recentVideos, forKey: KOUserDefaultKeyConstants.recentVideos)
            self.viewDelegate?.updateRecentVideosList()
        }
    }
    
    func clearAllBookmarks() {
        UserDefaults.standard.removeObject(forKey: KOUserDefaultKeyConstants.recentVideos)
    }
    
    func getRecentVideos() -> [URL] {
        return self.recentVideos
    }
    
    func removeCroppedRect() {
        self.croppedRect = nil
        self.viewDelegate?.closePartOfScreenPicker()
    }
    
    func setCropped(Rect rect: NSRect?, displayId: CGDirectDisplayID) {
        if let screen = NSScreen.screens.first(where: { $0.getScreenNumber() == displayId }) {
            if rect != nil {
                self.croppedRect = rect
            }
            self.setCurrentScreen(screen)
        }
        self.viewDelegate?.closePartOfScreenPicker()
    }
    
    func getCroppedRect() -> NSRect? {
        return self.croppedRect
    }
    
    func isRecordingPartOfWindow() -> Bool {
        return self.croppedRect != nil
    }
    
    func resetProperties() {
        self.screenId = NSScreen.screens[0].getScreenNumber()
        self.croppedRect = nil
    }
}
