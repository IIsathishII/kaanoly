//
//  KOWindowsCoordinator.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import Quartz

class KOWindowsCoordinator {
    
    var statusItem: NSStatusItem
    var menu: NSMenu
    var overlayWindow: KOOverlayWindow?
    var homeWindow: KOHomeWindow?
    var items: [NSStatusItem]
    
    var propertiesManager : KOPropertiesDataManager?
    
    var isDone = false
    var displayStream : CGDisplayStream?
    
    init() {
        menu = NSMenu.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Kaanoly"
        items = []
        self.setUpMenu()
    }
    
    func setUpMenu() {
        let recordItem = NSMenuItem.init(title: "Open Recording", action: #selector(openRecordingLobby), keyEquivalent: "r")
        recordItem.target = self
        menu.addItem(recordItem)
        self.statusItem.menu = menu
    }
    
    @objc func openRecordingLobby() {
        self.propertiesManager = KOPropertiesStore.init()
        self.propertiesManager?.viewDelegate = self
        if homeWindow == nil {
            KORecordingCoordinator.sharedInstance.setupRecorder(propertiesManager: self.propertiesManager)
            
            overlayWindow = KOOverlayWindow.init()
            overlayWindow?.setup(propertiesManager: self.propertiesManager)
            overlayWindow?.level = .screenSaver
            overlayWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .transient]
            overlayWindow?.orderFrontRegardless()
            
            homeWindow = KOHomeWindow.init()
            homeWindow?.setup(propertiesManager: self.propertiesManager)
//            homeWindow?.level = NSWindow.Level.init(NSWindow.Level.screenSaver.rawValue+1)
            homeWindow?.level = NSWindow.Level.init(Int(CGShieldingWindowLevel()))
            homeWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .managed]
            homeWindow?.orderFrontRegardless()
            
//            var displays : [CGDirectDisplayID] = Array.init(repeating: 0, count: 10)
//            var count : uint32 = 0
//            let error = CGGetOnlineDisplayList (10, &displays, &count)
//            print(error, displays, count)
        }
        
//        self.captureDisplayStream()
    }
    
    @objc func captureDisplayStream() {
        let mainDisplay = CGMainDisplayID()
        let displayBounds = CGDisplayBounds(mainDisplay)
        let recordingQueue = DispatchQueue.global(qos: .background)
        
        let displayStreamProps : [CFString : Any] = [
          CGDisplayStream.preserveAspectRatio: kCFBooleanTrue,
          CGDisplayStream.showCursor:          kCFBooleanTrue,
          CGDisplayStream.minimumFrameTime:    1.0/60.0,
        ]

        displayStream = CGDisplayStream.init(dispatchQueueDisplay: mainDisplay, outputWidth: Int(displayBounds.width), outputHeight: Int(displayBounds.height), pixelFormat: Int32(kCVPixelFormatType_32BGRA), properties: displayStreamProps as CFDictionary, queue: recordingQueue) { (frameStatus, displayTime, frameSurface, updateRef) in
            if frameSurface == nil { return }
            var pixelBuffer : Unmanaged<CVPixelBuffer>? = nil
            CVPixelBufferCreateWithIOSurface(CFAllocatorGetDefault().takeRetainedValue(), frameSurface!, nil, &pixelBuffer)
            
//            print("#####", pixelBuffer?.takeRetainedValue())
            if !self.isDone, frameSurface != nil, pixelBuffer != nil {
                let ciImage = CIImage.init(cvPixelBuffer: pixelBuffer!.takeRetainedValue())
//                let ciImageRep = NSCIImageRep.init(ciImage: ciImage)
//                let image = NSImage.init(size: ciImageRep.size)
//                image.addRepresentation(ciImageRep)
                let recordingDest = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("test.jpg")
                let bitmapImage = NSBitmapImageRep.init(ciImage: ciImage)
                try? bitmapImage.representation(using: .jpeg, properties: [:])?.write(to: recordingDest, options: .atomic)
//                self.isDone = true
            }
//            var count : Int = 0
//            let rects = updateRef?.getRects(.dirtyRects, rectCount: &count)
//            let buffer = UnsafeBufferPointer.init(start: rects, count: count)
//            let array = Array(buffer)
//            print("#########", frameStatus.rawValue, displayTime, frameSurface, updateRef, count, array)
        }
        
        displayStream?.start()
    }
    
    deinit {
        
    }
}

extension KOWindowsCoordinator : KOWindowsCoordinatorDelegate {
    
    func change(Source source: KOMediaSettings.MediaSource) {
        self.overlayWindow?.overlayViewController.presenterDelegate?.handleSourceChanged()
    }
    
    func change(Screen screen: NSScreen) {
        self.overlayWindow?.setFrame(screen.frame, display: true, animate: false)
        self.overlayWindow?.overlayViewController.resetCameraPreviewPosition()
    }
}
