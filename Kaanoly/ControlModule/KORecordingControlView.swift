//
//  KORecordingControlView.swift
//  Kaanoly
//
//  Created by SathishKumar on 17/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KORecordingControlView : NSView {
    
    var stopButton : NSButton
    var pauseButton : NSButton
    var deleteButton : NSButton
    
    weak var coordinatorDelegate : KOWindowsCoordinatorDelegate?
    
    init() {
        stopButton = NSButton.init()
        pauseButton = NSButton.init()
        deleteButton = NSButton.init()
        super.init(frame: .zero)
        
        self.wantsLayer = true
        self.layer?.cornerRadius = 5
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.layer?.borderColor = NSColor.init(named: "recordingControlBorder")?.cgColor
        self.layer?.borderWidth = 0.5
        
        self.stopButton.target = self
        self.pauseButton.target = self
        self.deleteButton.target = self
        
        self.stopButton.action = #selector(stopRecording)
        self.pauseButton.action = #selector(pauseRecording)
        self.deleteButton.action = #selector(cancelRecording)
        
        self.stopButton.image = NSImage.init(named: "stopRecord")!
        self.pauseButton.image = NSImage.init(named: "pauseRecord")!
        self.pauseButton.alternateImage = NSImage.init(named: "playRecord")!
        self.deleteButton.image = NSImage.init(named: "cancelRecord")!
        
        self.pauseButton.setButtonType(.toggle)
        
        self.stopButton.imagePosition = .imageOnly
        self.pauseButton.imagePosition = .imageOnly
        self.deleteButton.imagePosition = .imageOnly
        
        self.stopButton.isBordered = false
        self.pauseButton.isBordered = false
        self.deleteButton.isBordered = false
        
        self.addSubview(self.stopButton)
        self.addSubview(self.pauseButton)
        self.addSubview(self.deleteButton)
        
        self.stopButton.translatesAutoresizingMaskIntoConstraints = false
        self.pauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.stopButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stopButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.stopButton.widthAnchor.constraint(equalToConstant: 36),
            self.stopButton.heightAnchor.constraint(equalToConstant: 36),
            
            self.pauseButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.pauseButton.topAnchor.constraint(equalTo: self.stopButton.bottomAnchor),
            self.pauseButton.widthAnchor.constraint(equalToConstant: 36),
            self.pauseButton.heightAnchor.constraint(equalToConstant: 36),
            
            self.deleteButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.deleteButton.topAnchor.constraint(equalTo: self.pauseButton.bottomAnchor),
            self.deleteButton.widthAnchor.constraint(equalToConstant: 36),
            self.deleteButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(coordinatorDelegate: KOWindowsCoordinatorDelegate?) {
        self.coordinatorDelegate = coordinatorDelegate
    }
    
    @objc func stopRecording() {
        self.coordinatorDelegate?.stopRecording()
    }
    
    @objc func pauseRecording() {
//        self.pauseButton.state = (self.pauseButton.state == .on) ? .off : .on
        if self.pauseButton.state == .on {
            self.coordinatorDelegate?.pauseRecording()
        } else {
            self.coordinatorDelegate?.resumeRecording()
        }
    }
    
    @objc func cancelRecording() {
        
    }
}
