//
//  KORecordingControlWindow.swift
//  Kaanoly
//
//  Created by SathishKumar on 18/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KORecordingControlWindow : NSWindow {
    
    let recordingController = KORecordingControlViewController.init()
    
    init() {
        super.init(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor.clear
        self.contentViewController = recordingController
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?, coordinatorDelegate: KOWindowsCoordinatorDelegate?) {
        self.recordingController.setup(propertiesManager: propertiesManager, coordinatorDelegate: coordinatorDelegate)
    }
    
    func setControlFrame() {
        if let screenFrame = self.recordingController.propertiesManager?.getCurrentScreenFrame() {
            var xOrigin = screenFrame.origin.x
            var yOrigin = screenFrame.origin.y+((screenFrame.size.height-self.recordingController.controlView.frame.size.height)/2)
            if self.recordingController.propertiesManager?.isRecordingPartOfWindow() == true, let displayScreenFrame = self.recordingController.propertiesManager?.getCurrentScreen()?.frame {
                xOrigin = screenFrame.origin.x-self.recordingController.controlView.frame.size.width
                yOrigin = (2*displayScreenFrame.origin.y+displayScreenFrame.size.height-screenFrame.origin.y-screenFrame.size.height)//+((screenFrame.size.height-self.recordingController.controlView.frame.size.height)/2)
            }
            self.setFrame(NSRect.init(x: xOrigin, y: yOrigin, width: self.recordingController.controlView.frame.size.width, height: self.recordingController.controlView.frame.size.height), display: true)
        }
    }
}

class KORecordingControlViewController : NSViewController {
    
    let controlView = KORecordingControlView.init()
    weak var coordinatorDelegate : KOWindowsCoordinatorDelegate?
    weak var propertiesManager : KOPropertiesDataManager?
    
    override func loadView() {
        self.view = NSFlippedView.init()
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?, coordinatorDelegate: KOWindowsCoordinatorDelegate?) {
        self.coordinatorDelegate = coordinatorDelegate
        self.propertiesManager = propertiesManager
        self.controlView.setup(coordinatorDelegate: coordinatorDelegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.setupRecordingControl()
    }
    
    func setupRecordingControl() {
        self.view.addSubview(self.controlView)
        self.controlView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.controlView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.controlView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.controlView.widthAnchor.constraint(equalToConstant: 36),
            self.controlView.heightAnchor.constraint(equalToConstant: 116)
        ])
    }
}
