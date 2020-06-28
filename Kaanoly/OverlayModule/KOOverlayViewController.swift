//
//  KOOverlayViewController.swift
//  Kaanoly
//
//  Created by SathishKumar on 14/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOOverlayViewController : NSViewController {
    
    var cameraPreviewController: KOCameraPreviewViewController?
    var cameraPreviewView : NSView?
    var cameraPreviewSize = CameraPreviewConstants.Size.small
    
    override func loadView() {
        view = NSFlippedView.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        self.view.frame = NSRect.init(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
        self.view.wantsLayer = true
        self.view.layer?.borderColor = NSColor.red.cgColor
        self.view.layer?.borderWidth = 3
    }
    
    func setCameraPreview() {
        let size = KORecordingCoordinator.sharedInstance.getPreviewLayerSize()
        let height = cameraPreviewSize*CGFloat(size.1)/CGFloat(size.0)
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        var previewFrame = cameraPreviewView?.frame ?? .zero
        if cameraPreviewController == nil {
            cameraPreviewController = KOCameraPreviewViewController.init()
            cameraPreviewView = cameraPreviewController?.view
            cameraPreviewController?.previewView.delegate = self
            self.view.addSubview(cameraPreviewView!)
            previewFrame = NSRect.init(x: 24, y: screenFrame.height-height-24, width: cameraPreviewSize, height: height)
        }
        if self.cameraPreviewSize == CameraPreviewConstants.Size.large {
            previewFrame = NSRect.init(x: (screenFrame.size.width-cameraPreviewSize)/2, y: (screenFrame.size.height-height)/2, width: cameraPreviewSize, height: height)
        } else {
            previewFrame = NSRect.init(x: previewFrame.origin.x, y: previewFrame.origin.y, width: cameraPreviewSize, height: height)
        }
        cameraPreviewView?.frame = previewFrame
    }
    
    func removeCameraPreview() {
        self.cameraPreviewView?.removeFromSuperview()
        self.cameraPreviewView = nil
        self.cameraPreviewController = nil
    }
}

extension KOOverlayViewController : KOCameraPreviewDelegate {
    
    func moveCameraPreview(locX: CGFloat, locY: CGFloat) {
        self.cameraPreviewView?.setFrameOrigin(NSPoint.init(x: locX, y: locY))
    }
}

class NSFlippedView : NSView {
    
    override var isFlipped: Bool {
        return true
    }
}
