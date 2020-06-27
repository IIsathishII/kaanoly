//
//  KOHomeViewController.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOHomeViewController : NSViewController {
    
    var delegate: KOWindowsCoordinatorDelegate?
    var startRecordingButton = NSButton.init()
    var isRecording = false
    
    override func loadView() {
        self.view = NSView.init()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.preferredContentSize = NSSize.init(width: 400, height: 300)
        self.setSourcePopup()
        self.setRecordingButton()
    }
    
    func setSourcePopup() {
        var sourceList = NSPopUpButton.init(frame: .zero, pullsDown: false)
        sourceList.target = self
        sourceList.action = #selector(selectSource(_:))
        sourceList.addItems(withTitles: ["Camera+Screen", "Screen", "Camera"])
        self.view.addSubview(sourceList)
        sourceList.translatesAutoresizingMaskIntoConstraints = false
        var newConstraints = [NSLayoutConstraint]()
        newConstraints.append(sourceList.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24))
        newConstraints.append(sourceList.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 48))
        NSLayoutConstraint.activate(newConstraints)
    }
    
    @objc func selectSource(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        if index == 0 {
            self.delegate?.change(Source: [.camera, .screen, .audio])
        } else if index == 1 {
            self.delegate?.change(Source: [.screen, .audio])
        } else if index == 2 {
            self.delegate?.change(Source: [.camera, .audio])
        }
    }
    
    func setRecordingButton() {
        self.startRecordingButton.bezelStyle = .rounded
        self.startRecordingButton.title = "Start Recording..."
        self.startRecordingButton.target = self
        self.startRecordingButton.action = #selector(beginRecording)
        
        self.view.addSubview(self.startRecordingButton)
        self.startRecordingButton.translatesAutoresizingMaskIntoConstraints = false
        var recordingButtonConstraints = [NSLayoutConstraint]()
        recordingButtonConstraints.append(self.startRecordingButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
        recordingButtonConstraints.append(self.startRecordingButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor))
        NSLayoutConstraint.activate(recordingButtonConstraints)
    }
    
    @objc func beginRecording() {
        self.isRecording = !self.isRecording
        self.startRecordingButton.title = self.isRecording ? "End Recording!" : "Start Recording..."
        if self.isRecording {
            KORecordingCoordinator.sharedInstance.beginRecording()
        } else {
            KORecordingCoordinator.sharedInstance.endRecording()
        }
    }
}
