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
    var colorProps = KOColorProperties.sharedInstance
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
        self.view.layer?.borderColor = colorProps.cameraPreviewBorderColor.cgColor
        self.view.layer?.borderWidth = 1
        self.view.layer?.cornerRadius = 4
        self.setupPreview()
    }
    
    func setupPreview() {
        previewView.wantsLayer = true
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
    
    override func viewWillLayout() {
        super.viewWillLayout()
        self.previewView.layer?.frame = self.view.frame
    }
}
