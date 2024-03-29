//
//  KOWindowsCoordinator.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import Quartz
import AVFoundation

class KOWindowsCoordinator : NSObject {
    
    var statusItem: NSStatusItem
    var menu: NSMenu
    var overlayWindow: KOOverlayWindow?
    var homeWindowController: NSWindowController?
    var controlWindow : KORecordingControlWindow?
    var countDownWindow : KOCountDownWindow?

    var partOfScreenPickerWindows : [CGDirectDisplayID: KOPartOfScreenPickerWindow] = [:]
    
    var propertiesManager : KOPropertiesDataManager?
    
    var isDone = false
    var displayStream : CGDisplayStream?
    
    var recentVideosList : KORecentLocalVideosMenuView!
    
    override init() {
        self.propertiesManager = KOPropertiesStore.init()
        menu = NSMenu.init()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        statusItem.button?.title = "Vime"
        statusItem.button?.image = NSImage.init(named: "Menu_icon")!
        super.init()
        self.setUpMenu(self.menu)
        self.propertiesManager?.viewDelegate = self
        self.handleInputPermissions()
    }
    
    func handleInputPermissions() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if videoStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
                let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
                if audioStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: .audio) { (isGranted) in }
                }
            }
        }
    }
    
    @objc func openRecordingLobby() {
        var homeWindow : KOHomeWindow? = self.homeWindowController?.window as? KOHomeWindow
        if homeWindow == nil {
            KORecordingCoordinator.sharedInstance.setupRecorder(propertiesManager: self.propertiesManager)
            self.propertiesManager?.resetProperties()
            
            overlayWindow = KOOverlayWindow.init()
            overlayWindow?.setup(propertiesManager: self.propertiesManager)
            overlayWindow?.level = .screenSaver
            overlayWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .transient]
            overlayWindow?.orderFrontRegardless()
            
            homeWindow = KOHomeWindow.init()
            homeWindow?.delegate = self
            homeWindow?.setup(propertiesManager: self.propertiesManager, coordinatorDelegate: self)
//            homeWindow?.level = NSWindow.Level.init(NSWindow.Level.screenSaver.rawValue+1)
            homeWindow?.level = NSWindow.Level.init(Int(CGShieldingWindowLevel()))
            homeWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone, .managed]
            self.homeWindowController = NSWindowController.init()
            self.homeWindowController?.window = homeWindow
            homeWindow?.orderFrontRegardless()
            homeWindow?.center()
            homeWindow?.makeKey()
            
            controlWindow = KORecordingControlWindow.init()
            controlWindow?.setup(propertiesManager: propertiesManager, coordinatorDelegate: self)
            self.overlayWindow?.addChildWindow(controlWindow!, ordered: .above)
            controlWindow?.level = .screenSaver
            controlWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone, .transient]
            controlWindow?.orderFrontRegardless()
            controlWindow?.setControlFrame()
            controlWindow?.isEnabled = false
//            controlWindow?.setFrame(NSRect.init(origin: CGPoint.init(x: 0, y: 600), size: CGSize.init(width: 36, height: 112)), display: true)
            
            NSApp.presentationOptions = [.autoHideDock]
            NSApp.setActivationPolicy(.accessory)
            
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
        self.controlWindow?.setControlFrame()
    }
    
    func beginRecording(countDownCompletion: @escaping () -> ()) {
        statusItem.button?.isEnabled = false
        self.homeWindowController?.window?.orderOut(nil)
        
        self.countDownWindow = KOCountDownWindow.init()
        self.overlayWindow?.addChildWindow(countDownWindow!, ordered: .above)
        self.countDownWindow?.level = .screenSaver
        self.countDownWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone, .transient]
        self.countDownWindow?.orderFrontRegardless()
        self.countDownWindow?.setupFrame()
        
        // Sets Count Down Indicator to the middle of the recording screen
        if var rect = self.propertiesManager?.getCurrentScreenFrame() {
            var originY = rect.origin.y+rect.height/2+self.countDownWindow!.frame.height/2
            if let displayScreenFrame = self.propertiesManager?.getCurrentScreen()?.frame, let isCropped = self.propertiesManager?.isRecordingPartOfWindow() {
                originY = displayScreenFrame.size.height-rect.origin.y-rect.height/2+self.countDownWindow!.frame.height/2
            }
            self.countDownWindow?.setFrameTopLeftPoint(NSPoint.init(x: rect.origin.x+rect.width/2-self.countDownWindow!.frame.size.width/2, y: originY))
        }

        self.countDownWindow?.startCount {
            self.countDownWindow?.orderOut(nil)
            self.countDownWindow = nil
            NSStatusBar.system.removeStatusItem(self.statusItem)
            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//            self.statusItem.button?.title = "Stop"
            self.statusItem.button?.image = NSImage.init(named: "Stop_Record_Menu_Icon")!
            self.statusItem.button?.target = self
            self.statusItem.button?.action = #selector(self.stopRecording)
            self.controlWindow?.isEnabled = true
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                timer.invalidate()
                let startRecordSound : UInt32 = 1113
                AudioServicesPlaySystemSound(startRecordSound)
                countDownCompletion()
            }
        }
    }
    
    @objc func stopRecording() {
        let stopRecordSound : UInt32 = 1114
        AudioServicesPlaySystemSound(stopRecordSound)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        statusItem.button?.title = "Vime"
        statusItem.button?.image = NSImage.init(named: "Menu_icon")!
        statusItem.menu = self.menu
        self.controlWindow?.orderOut(nil)
        self.controlWindow = nil
        self.overlayWindow?.orderOut(nil)
        self.overlayWindow = nil
        self.homeWindowController?.window = nil
        self.homeWindowController = nil
        KORecordingCoordinator.sharedInstance.endRecording()
        KORecordingCoordinator.sharedInstance.destroyRecorder()
        
        KOReviewPrompter.requestReview()
    }
    
    func stopRecordingAbruptly() {
        self.stopRecording()

        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.messageText = "Recording Stopped"
        alert.informativeText = "The recording has been stopped as the screen being recorded was disconnected."
        alert.alertStyle = .warning
        alert.runModal()
    }
    
    func updateRecentVideosList() {
//        self.menu = NSMenu.init()
//        self.setUpMenu()
        self.menu = NSMenu.init()
        self.setUpMenu(self.menu)
    }
    
    func pauseRecording() {
        KORecordingCoordinator.sharedInstance.pauseRecording()
    }
    
    func resumeRecording() {
        KORecordingCoordinator.sharedInstance.resumeRecording()
    }
    
    func cancelRecording() {
        KORecordingCoordinator.sharedInstance.cancelRecording()
        self.stopRecording()
    }
    
    func openPartOfScreenPicker() {
        self.overlayWindow?.orderOut(nil)
        self.homeWindowController?.window?.orderOut(nil)

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
        self.homeWindowController?.window?.makeKey()
        self.homeWindowController?.window?.orderFrontRegardless()
        self.controlWindow?.setControlFrame()
        
        if self.propertiesManager?.getCroppedRect() == nil {
            (self.homeWindowController?.window as? KOHomeWindow)?.homeViewController.setScreenDropDownMenu()
        }
        self.overlayWindow?.overlayViewController.cameraPreviewController?.updatePreview()
        self.overlayWindow?.overlayViewController.resetCameraPreviewPosition()
    }
    
    func clearPartOfScreenSelectionsInAllScreens() {
        for key in self.partOfScreenPickerWindows.keys {
            self.partOfScreenPickerWindows[key]?.pickerViewController.clearPartOfScreenSelection()
        }
    }
    
    func didOpenDirectoryPanel() {
        self.overlayWindow?.orderOut(nil)
        self.controlWindow?.orderOut(nil)
        self.homeWindowController?.window?.orderOut(nil)
    }
    
    func didCloseDirectoryPanel() {
        self.overlayWindow?.orderFrontRegardless()
        self.controlWindow?.orderFrontRegardless()
        self.homeWindowController?.window?.orderFrontRegardless()
    }
}

extension KOWindowsCoordinator : NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        if let pickerWindow = notification.object as? KOPartOfScreenPickerWindow {
            self.partOfScreenPickerWindows[pickerWindow.displayId] = nil
        } else if let homeWindow = notification.object as? KOHomeWindow {
            self.controlWindow?.orderOut(nil)
            self.controlWindow = nil
            self.overlayWindow?.orderOut(nil)
            self.overlayWindow = nil
            self.homeWindowController?.window = nil
            self.homeWindowController = nil
        }
    }
}

extension KOWindowsCoordinator : NSMenuDelegate {
    
    func setUpMenu(_ currMenu : NSMenu) {
        let recordItem = NSMenuItem.init(title: "Open Recording Lobby", action: #selector(openRecordingLobby), keyEquivalent: "")
        recordItem.target = self
        currMenu.addItem(recordItem)
        currMenu.addItem(NSMenuItem.separator())
        
        if let dir = self.propertiesManager?.getStorageDirectory() {
            let recentVideos = self.propertiesManager?.getRecentVideos() ?? []
            if !recentVideos.isEmpty {
                let item = NSMenuItem.init(title: "Recent Videos from '\(dir.lastPathComponent)'", action: nil, keyEquivalent: "")
                currMenu.addItem(item)
            }
            for video in recentVideos {
                let item = NSMenuItem.init(title: "Video", action: #selector(recentVideoSelected(_:)), keyEquivalent: "")
                let itemView = KORecentLocalVideosMenuView.init(url: video)
                itemView.autoresizingMask = [.width, .height]
                item.view = itemView
                item.target = self
                currMenu.addItem(item)
            }
            if !recentVideos.isEmpty {
                let item = NSMenuItem.init(title: "Open '\(dir.lastPathComponent)'", action: #selector(openLocalDir), keyEquivalent: "")
                item.target = self
                currMenu.addItem(item)
            }
            currMenu.addItem(NSMenuItem.separator())
        }
        
        let quitItem = NSMenuItem.init(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        currMenu.addItem(quitItem)
        self.statusItem.menu = currMenu
        currMenu.delegate = self
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        self.setUpMenu(menu)
    }
    
    @objc func recentVideoSelected(_ item: NSMenuItem) {
        if let url = (item.view as? KORecentLocalVideosMenuView)?.assetUrl {
            url.startAccessingSecurityScopedResource()
            NSWorkspace.shared.open(url)
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    @objc func openLocalDir() {
        if let dir = self.propertiesManager?.getStorageDirectory() {
            dir.startAccessingSecurityScopedResource()
            NSWorkspace.shared.open(dir)
            dir.stopAccessingSecurityScopedResource()
        }
    }
}

extension KOWindowsCoordinator : NSUserNotificationCenterDelegate {
    
}
