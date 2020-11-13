//
//  KOWindowsCoordinator.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import Quartz

class KOWindowsCoordinator : NSObject {
    
    var statusItem: NSStatusItem
    var menu: NSMenu
    var overlayWindow: KOOverlayWindow?
    var homeWindow: KOHomeWindow?

    var partOfScreenPickerWindows : [CGDirectDisplayID: KOPartOfScreenPickerWindow] = [:]
    
    var propertiesManager : KOPropertiesDataManager?
    
    var isDone = false
    var displayStream : CGDisplayStream?
    
    override init() {
        self.propertiesManager = KOPropertiesStore.init()
        menu = NSMenu.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Kaanoly"
        super.init()
        self.setUpMenu()
        self.propertiesManager?.viewDelegate = self
    }
    
    func setUpMenu() {
        let recentVideoList = NSMenuItem.init(title: "Recent Videos", action: nil, keyEquivalent: "")
        let recentVideoView = KORecentLocalVideosMenuView.init(paths: self.propertiesManager?.getRecentVideos() ?? [])
        recentVideoView.autoresizingMask = [.width, .height]
        recentVideoList.view = recentVideoView
        menu.addItem(recentVideoList)
        
        menu.addItem(NSMenuItem.separator())
        
        let recordItem = NSMenuItem.init(title: "Open Recording", action: #selector(openRecordingLobby), keyEquivalent: "r")
        recordItem.target = self
        menu.addItem(recordItem)
        
        let quitItem = NSMenuItem.init(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)
        self.statusItem.menu = menu
    }
    
    @objc func openRecordingLobby() {
        if homeWindow == nil {
            KORecordingCoordinator.sharedInstance.setupRecorder(propertiesManager: self.propertiesManager)
            
            overlayWindow = KOOverlayWindow.init()
            overlayWindow?.setup(propertiesManager: self.propertiesManager)
            overlayWindow?.level = .screenSaver
            overlayWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .transient]
            overlayWindow?.orderFrontRegardless()
            
            homeWindow = KOHomeWindow.init()
            homeWindow?.setup(propertiesManager: self.propertiesManager, coordinatorDelegate: self)
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
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
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
    
    func beginRecording() {
        NSStatusBar.system.removeStatusItem(statusItem)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Stop"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(stopRecording)
        self.homeWindow?.orderOut(nil)
    }
    
    @objc func stopRecording() {
        menu = NSMenu.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Kaanoly"
        self.setUpMenu()
        KORecordingCoordinator.sharedInstance.endRecording()
        KORecordingCoordinator.sharedInstance.destroyRecorder()
        self.overlayWindow?.orderOut(nil)
        self.overlayWindow = nil
        self.homeWindow = nil
    }
    
    func openPartOfScreenPicker() {
        self.overlayWindow?.orderOut(nil)
        self.homeWindow?.orderOut(nil)

        self.partOfScreenPickerWindows = [:]
        for screen in NSScreen.screens {
            guard let displayId = screen.getScreenNumber() else { continue }
            let pickerWindow = KOPartOfScreenPickerWindow.init(displayId: displayId)
            pickerWindow.delegate = self
            self.partOfScreenPickerWindows[displayId] = pickerWindow
            pickerWindow.setup(propertiesManager: self.propertiesManager)
            pickerWindow.level = .screenSaver
            pickerWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .transient]
            pickerWindow.makeKey()
            pickerWindow.setFrame(screen.frame, display: true)
            pickerWindow.orderFrontRegardless()
//            pickerWindow.makeKeyAndOrderFront(nil)
        }
    }
    
    func closePartOfScreenPicker() {
        for key in self.partOfScreenPickerWindows.keys {
            self.partOfScreenPickerWindows[key]?.orderOut(nil)
        }
        self.overlayWindow?.orderFrontRegardless()
        self.homeWindow?.makeKey()
        self.homeWindow?.orderFrontRegardless()
    }
    
    func clearPartOfScreenSelectionsInAllScreens() {
        for key in self.partOfScreenPickerWindows.keys {
            self.partOfScreenPickerWindows[key]?.pickerViewController.clearPartOfScreenSelection()
        }
    }
}

extension KOWindowsCoordinator : NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        if let pickerWindow = notification.object as? KOPartOfScreenPickerWindow {
            self.partOfScreenPickerWindows[pickerWindow.displayId] = nil
        }
    }
}
