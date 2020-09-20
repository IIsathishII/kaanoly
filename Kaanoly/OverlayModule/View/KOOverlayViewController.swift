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
    
    var presenterDelegate : KOOverlayPresenterDelegate?
    
    override func loadView() {
        view = NSFlippedView.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.borderColor = NSColor.red.cgColor
        self.view.layer?.borderWidth = 2
        if let screenFrame = self.presenterDelegate?.propertiesManager?.getCurrentScreenFrame() {
            self.view.frame = NSRect.init(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
        }
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.presenterDelegate = KOOverlayPresenter.init()
        self.presenterDelegate?.viewDelegate = self
        self.presenterDelegate?.propertiesManager = propertiesManager
        self.presenterDelegate?.handleSourceChanged()
    }
    
    
}

extension KOOverlayViewController : KOOverlayViewDelegate {

    func setCameraPreview() {
        guard let scale = self.presenterDelegate?.getPreviewScale(), let screenFrame = self.presenterDelegate?.propertiesManager?.getCurrentScreenFrame() else { return }
        let size = KORecordingCoordinator.sharedInstance.getPreviewLayerSize()
        let width = screenFrame.width * scale
        let height = width * CGFloat(size.1)/CGFloat(size.0)
        var previewFrame = cameraPreviewView?.frame ?? .zero
        if cameraPreviewController == nil {
            cameraPreviewController = KOCameraPreviewViewController.init()
            cameraPreviewController?.setup(propertiesManager: self.presenterDelegate?.propertiesManager)
            cameraPreviewView = cameraPreviewController?.view
            cameraPreviewController?.previewView.presenterDelegate?.viewDelegate = self
            cameraPreviewController?.previewView.presenterDelegate?.overlayPresenterDelegate = self.presenterDelegate
            self.view.addSubview(cameraPreviewView!)
            previewFrame = NSRect.init(x: CameraPreviewConstants.horizontalSpacing, y: screenFrame.height-height-CameraPreviewConstants.verticalSpacing, width: width, height: height)
        }
        
        if self.presenterDelegate?.propertiesManager?.getSource().contains(.camera) == true {
            if self.presenterDelegate?.propertiesManager?.getSource().contains(.screen) == true {
                previewFrame = NSRect.init(x: previewFrame.origin.x, y: previewFrame.origin.y, width: width, height: height)
            } else {
                previewFrame = NSRect.init(x: (screenFrame.size.width-width)/2, y: (height)/2, width: width, height: height)
            }
        }
//        cameraPreviewView?.frame = previewFrame
        self.cameraPreviewView?.animator().setFrameOrigin(previewFrame.origin)
        self.cameraPreviewView?.animator().setFrameSize(previewFrame.size)
    }
    
    func removeCameraPreview() {
        self.cameraPreviewView?.removeFromSuperview()
        self.cameraPreviewView = nil
        self.cameraPreviewController = nil
    }
    
    func resetCameraPreviewPosition() {
        guard let scale = self.presenterDelegate?.getPreviewScale(), let screenFrame = self.presenterDelegate?.propertiesManager?.getCurrentScreenFrame() else { return }
        let size = KORecordingCoordinator.sharedInstance.getPreviewLayerSize()
        let width = screenFrame.width * scale
        let height = width * CGFloat(size.1)/CGFloat(size.0)
        let previewFrame = NSRect.init(x: CameraPreviewConstants.horizontalSpacing, y: screenFrame.height-height-CameraPreviewConstants.verticalSpacing, width: width, height: height)
        self.cameraPreviewView?.animator().setFrameOrigin(previewFrame.origin)
        self.cameraPreviewView?.animator().setFrameSize(previewFrame.size)
    }
    
    func moveCameraPreview(locX: CGFloat, locY: CGFloat, isAnimated: Bool) {
        if isAnimated {
            self.cameraPreviewView?.animator().setFrameOrigin(NSPoint.init(x: locX, y: locY))
        } else {
            self.cameraPreviewView?.setFrameOrigin(NSPoint.init(x: locX, y: locY))
        }
    }
    
    func adjustCameraPreviewStyle(isPinnedToCorner: Bool) {
        if isPinnedToCorner {
            self.cameraPreviewView?.layer?.cornerRadius = 0
        } else {
            self.cameraPreviewView?.layer?.cornerRadius = 4
        }
    }
    
    func resizeCameraPreview(delX: CGFloat, delY: CGFloat) {
        self.cameraPreviewView?.setFrameSize(NSSize.init(width: cameraPreviewView!.frame.size.width+delX, height: cameraPreviewView!.frame.size.height+delY))
    }
}

class NSFlippedView : NSView {
    
    override var isFlipped: Bool {
        return true
    }
}
