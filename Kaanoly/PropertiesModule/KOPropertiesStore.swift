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
    private var captureMouseClick = (UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.captureMouseClick) as? Bool) ?? false
    private var isMirrored = (UserDefaults.standard.value(forKey: KOUserDefaultKeyConstants.mirrorCamera) as? Bool) ?? true
    private var storageDirectory : URL? = {
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
    }()
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
        self.screen = NSScreen.screens[0]
        KOObjectSubscriber.onObjectDeinit(forObject: self.screen!, callbackId: "", callback: {
            self.screen = NSScreen.screens[0]
        })
//        self.storageDirectory?.stopAccessingSecurityScopedResource()
//        self.clearUserDefaults()
    }
    
    func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: KOUserDefaultKeyConstants.storageDirectory)
        UserDefaults.standard.synchronize()
    }
    
    deinit {
        self.storageDirectory?.stopAccessingSecurityScopedResource()
    }
}

extension KOPropertiesStore : KOPropertiesDataManager {
    
    func getStorageDirectory() -> URL? {
        return self.storageDirectory
    }
    
    func setStorageDirectory(_ val: URL) {
//        self.storageDirectory?.stopAccessingSecurityScopedResource()
        self.storageDirectory = val
        if let data = try? val.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            UserDefaults.standard.setValue(data, forKey: KOUserDefaultKeyConstants.storageDirectory)
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
        return screen
    }
    
    func setCurrentScreen(_ screen: NSScreen) {
        self.screen = screen
        KORecordingCoordinator.sharedInstance.modifyRecorder(propertiesManager: self)
        self.viewDelegate?.change(Screen: screen)
    }
    
    func getCurrentScreenFrame() -> NSRect? {
        if self.croppedRect == nil {
            return screen?.frame
        } else {
            return self.croppedRect
        }
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
        }
    }
    
    func getRecentVideos() -> [URL] {
        return self.recentVideos
    }
    
    func setCropped(Rect rect: NSRect?, displayId: CGDirectDisplayID) {
        if rect != nil {
            self.screen = NSScreen.screens.first(where: { $0.getScreenNumber() == displayId })
        }
        self.croppedRect = rect
        self.viewDelegate?.closePartOfScreenPicker()
    }
    
    func getCroppedRect() -> NSRect? {
        return self.croppedRect
    }
}
