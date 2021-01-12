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
    var showOnlyOnHover = true {
        didSet {
            if self.showOnlyOnHover {
                self.recordingController.leadingConstraint.constant = -24
                self.recordingController.removeTrackingArea()
                self.recordingController.setTrackingArea()
            } else {
                self.recordingController.leadingConstraint.constant = 0
                self.recordingController.removeTrackingArea()
            }
        }
    }
    
    var isEnabled = true {
        didSet {
            if isEnabled {
                self.recordingController.controlView.enableAllButtons()
            } else {
                self.recordingController.controlView.disableAllButtons()
            }
        }
    }
    
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
                self.showOnlyOnHover = false
                xOrigin = screenFrame.origin.x-self.recordingController.controlView.frame.size.width
                yOrigin = 2*displayScreenFrame.origin.y+displayScreenFrame.size.height-self.recordingController.controlView.frame.size.height-screenFrame.origin.y-((screenFrame.size.height-self.recordingController.controlView.frame.size.height)/2)
            } else {
                self.showOnlyOnHover = true
            }
            self.setFrame(NSRect.init(x: xOrigin, y: yOrigin, width: self.recordingController.controlView.frame.size.width, height: self.recordingController.controlView.frame.size.height), display: true)
        }
    }
}

class KORecordingControlViewController : NSViewController {
    
    let controlView = KORecordingControlView.init()
    weak var coordinatorDelegate : KOWindowsCoordinatorDelegate?
    weak var propertiesManager : KOPropertiesDataManager?
    
    var trackingArea : NSTrackingArea?
    var leadingConstraint : NSLayoutConstraint!
    var hoverTimer : Timer?
    
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
        self.setTrackingArea()
    }
    
    func setupRecordingControl() {
        self.view.addSubview(self.controlView)
        self.controlView.translatesAutoresizingMaskIntoConstraints = false
        
        leadingConstraint = self.controlView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -24)
        NSLayoutConstraint.activate([
            leadingConstraint,
            self.controlView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.controlView.widthAnchor.constraint(equalToConstant: 36),
            self.controlView.heightAnchor.constraint(equalToConstant: 116)
        ])
    }
    
    func setTrackingArea() {
        self.trackingArea = NSTrackingArea.init(rect: self.view.bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        self.view.addTrackingArea(self.trackingArea!)
    }
    
    func removeTrackingArea() {
        if self.trackingArea != nil {
            self.view.removeTrackingArea(self.trackingArea!)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.hoverTimer?.invalidate()
        self.hoverTimer = nil
        NSAnimationContext.runAnimationGroup { (context) in
            context.duration = 0.2
            self.leadingConstraint.animator().constant = 0
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            NSAnimationContext.runAnimationGroup { (context) in
                context.duration = 0.2
                self.leadingConstraint.animator().constant = -24
            }
        })
    }
}
