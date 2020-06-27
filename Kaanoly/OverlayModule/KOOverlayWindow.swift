//
//  KOOverlayWindow.swift
//  Kaanoly
//
//  Created by SathishKumar on 31/05/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOOverlayWindow : NSWindow {
    
    private var source : KOMediaSettings.MediaSource
    var overlayViewController : KOOverlayViewController
    
    init(mediaSource: KOMediaSettings.MediaSource) {
        source = mediaSource
        overlayViewController = KOOverlayViewController.init()
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        super.init(contentRect: NSRect.init(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height), styleMask: [.borderless], backing: .buffered, defer: false)
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor.clear
        self.contentViewController = overlayViewController
        self.setupSource()
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    func setSource(_ source: KOMediaSettings.MediaSource) {
        self.source = source
    }
    
    func setupSource() {
        if source.contains([.screen, .camera]) {
            overlayViewController.cameraPreviewSize = CameraPreviewConstants.Size.small
            overlayViewController.setCameraPreview()
        } else if source.contains(.camera) {
            overlayViewController.cameraPreviewSize = CameraPreviewConstants.Size.large
            overlayViewController.setCameraPreview()
        } else if source.contains([.screen]) {
            overlayViewController.removeCameraPreview()
        }
    }
}
