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
    var cursorUtilitiesView = KOCursorUtilitiesView.init()
    
    var dimView : KODimView?
    var screenMask : CAShapeLayer?
    
    override func loadView() {
        view = NSFlippedView.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.masksToBounds = true
        self.view.layer?.borderColor = NSColor.red.cgColor
        self.view.layer?.borderWidth = 2
        if let screenFrame = self.presenterDelegate?.propertiesManager?.getCurrentScreenFrame() {
            self.view.frame = NSRect.init(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
        }
        self.setupCursorUtilityView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.presenterDelegate = KOOverlayPresenter.init()
        self.presenterDelegate?.viewDelegate = self
        self.presenterDelegate?.propertiesManager = propertiesManager
        self.presenterDelegate?.handleSourceChanged()
    }
    
    func setupCursorUtilityView() {
        self.view.addSubview(self.cursorUtilitiesView)
        self.cursorUtilitiesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.cursorUtilitiesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.cursorUtilitiesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.cursorUtilitiesView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.cursorUtilitiesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.view.sendSubviewToBack(self.cursorUtilitiesView)
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
        var previewFrame = NSRect.init(x: CameraPreviewConstants.horizontalSpacing, y: screenFrame.height-height-CameraPreviewConstants.verticalSpacing, width: width, height: height)
        self.dimView?.removeFromSuperview()
        self.dimView = nil
        self.screenMask = nil
        if let croppedRect = self.presenterDelegate?.propertiesManager?.getCroppedRect() {
            previewFrame.origin.x += croppedRect.origin.x
            previewFrame.origin.y = croppedRect.origin.y+croppedRect.height-height-CameraPreviewConstants.verticalSpacing
        }
        self.setupScreenMask()
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
            self.cameraPreviewController?.removeCornerRadius()
//            self.cameraPreviewView?.layer?.cornerRadius = 0
        } else {
            self.cameraPreviewController?.setCornerRadius()
//            self.cameraPreviewView?.layer?.cornerRadius = self.cameraPreviewController!.cornerRadius
        }
    }
    
    func resizeCameraPreview(delX: CGFloat, delY: CGFloat, delWidth: CGFloat, delHeight: CGFloat) {
        guard let previewFrame = self.cameraPreviewView?.frame else { return }
        self.cameraPreviewView?.setFrameOrigin(NSPoint.init(x: previewFrame.origin.x+delX, y: previewFrame.origin.y+delY))
        self.cameraPreviewView?.setFrameSize(NSSize.init(width: previewFrame.size.width+delWidth, height: previewFrame.size.height+delHeight))
    }
    
    func resizeCameraPreview(delX: CGFloat, delY: CGFloat) {
        
    }
    
    func setupScreenMask() {
        self.dimView = KODimView.init()
        self.dimView?.wantsLayer = true
        self.dimView?.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        self.view.addSubview(self.dimView!, positioned: .below, relativeTo: self.cameraPreviewView)
        self.dimView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.dimView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.dimView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.dimView!.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.dimView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        self.view.layoutSubtreeIfNeeded()
        if let cropRect = self.presenterDelegate?.propertiesManager?.getCroppedRect() {
            self.screenMask = CAShapeLayer.init()
            self.screenMask?.fillRule = .evenOdd
            let path = NSBezierPath.init(rect: self.dimView!.bounds)
            path.appendRect(cropRect)
            self.screenMask?.path = path.cgPath
            self.dimView?.layer?.mask = self.screenMask
        }
        
    }
}

class NSFlippedView : NSView {
    
    override var isFlipped: Bool {
        return true
    }
}

class KOCursorUtilitiesView : NSFlippedView {
    
}

class KODimView : NSFlippedView {
    
    override var isOpaque: Bool {
        return false
    }
}
