//
//  KOCameraPreviewViewController.swift
//  Kaanoly
//
//  Created by SathishKumar on 07/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOCameraPreviewViewController: NSViewController {
    
    var previewView : KOCameraPreviewMovableView = KOCameraPreviewMovableView.init()
    
    var presenterDelegate : KOCameraPreviewPresenterDelegate?
    
    let cornerRadius = CGFloat(4)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.presenterDelegate = KOCameraPreviewPresenter.init()
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.presenterDelegate?.propertiesManager = propertiesManager
    }
    
    override func loadView() {
        self.view = NSView.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        self.view.layer?.contents = NSImage.init(named: "CamreaPreviewBackground")
        self.view.layer?.contentsGravity = .resize
//        self.view.layer?.borderColor = KOStyleProperties.Color.cameraPreviewBorderColor.cgColor
//        self.view.layer?.borderWidth = 1
        self.setCornerRadius()
        self.setupPreview()
    }
    
    func setupPreview() {
        previewView.presenterDelegate = self.presenterDelegate
        previewView.wantsLayer = true
        previewView.layer?.backgroundColor = NSColor.black.cgColor
        let previewLayer = KORecordingCoordinator.sharedInstance.getPreviewLayer()
        previewView.layer = previewLayer
        previewLayer?.frame = previewView.frame
        self.view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        var newConstraints = [NSLayoutConstraint]()
        newConstraints.append(previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
        newConstraints.append(previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        newConstraints.append(previewView.topAnchor.constraint(equalTo: self.view.topAnchor))
        newConstraints.append(previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor))
        NSLayoutConstraint.activate(newConstraints)
    }
    
    func updatePreview() {
        self.previewView.layer = KORecordingCoordinator.sharedInstance.getPreviewLayer()
    }
    
    func removeCornerRadius() {
        self.view.layer?.cornerRadius = 0
    }
    
    func setCornerRadius() {
        self.view.layer?.cornerRadius = cornerRadius
    }
}
