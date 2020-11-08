//
//  KOHomeViewController.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import IOKit

class KOHomeViewController : NSViewController {

    var startRecordingButton = NSButton.init()
    var isRecording = false
    var mouseHighlighterOption = NSButton.init(title: "Enable Mouse Highlighter", target: self, action: #selector(toggleMouseHighlighter))
    var mirroredOption = NSButton.init(title: "Mirror Video", target: self, action: #selector(toggleMirror))
    
    var openButton = NSButton.init(title: " Open Location... ", target: self, action: #selector(selectFolderLocation))
    var sourceList = NSPopUpButton.init(frame: .zero, pullsDown: false)
    
    weak var propertiesManager : KOPropertiesDataManager? {
        didSet {
            self.setProperties()
        }
    }
    
    weak var viewDelegate : KOWindowsCoordinatorDelegate?
    
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
        self.setOpenButton()
        self.setSourcePopup()
        self.setScreenPopup()
        self.setRecordingButton()
        self.setMouseHighlighterCheckbox()
        self.setMirroredCheckbox()
    }
    
    @objc func selectFolderLocation() {
        let openPanel = NSOpenPanel.init()
        openPanel.canCreateDirectories = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
//        openPanel.level = self.view.window!.level
        let response = openPanel.runModal()
        self.propertiesManager?.setStorageDirectory(openPanel.url!)
        print("Response :::: ", response)
    }
    
    func setOpenButton() {
        openButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(openButton)
        NSLayoutConstraint.activate([
            openButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            openButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24)
        ])
    }
    
    func setSourcePopup() {
        sourceList.target = self
        sourceList.action = #selector(selectSource(_:))
        sourceList.addItems(withTitles: ["Camera+Screen", "Screen", "Camera"])
        self.view.addSubview(sourceList)
        sourceList.translatesAutoresizingMaskIntoConstraints = false
        var newConstraints = [NSLayoutConstraint]()
        newConstraints.append(sourceList.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24))
        newConstraints.append(sourceList.topAnchor.constraint(equalTo: self.openButton.bottomAnchor, constant: 18))
        NSLayoutConstraint.activate(newConstraints)
    }
    
    func setScreenPopup() {
        var screenList = NSPopUpButton.init(frame: .zero, pullsDown: false)
        screenList.target = self
        screenList.action = #selector(selectScreen(_:))
        var screenNames = [String]()
        for i in 0..<NSScreen.screens.count {
            screenNames.append("Screen \(i+1)" + (NSScreen.screens[i].getDeviceName() != nil ? " (\(NSScreen.screens[i].getDeviceName()!))" : ""))
        }
        screenList.addItems(withTitles: screenNames)
        screenList.addItem(withTitle: "Part of Screen")
        self.view.addSubview(screenList)
        screenList.translatesAutoresizingMaskIntoConstraints = false
        var newConstraints = [NSLayoutConstraint]()
        newConstraints.append(screenList.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24))
        newConstraints.append(screenList.topAnchor.constraint(equalTo: self.sourceList.bottomAnchor, constant: 18))
        NSLayoutConstraint.activate(newConstraints)
    }
    
    @objc func selectSource(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        if index == 0 {
            self.propertiesManager?.setSource([.camera, .screen, .audio])
        } else if index == 1 {
            self.propertiesManager?.setSource([.screen, .audio])
        } else if index == 2 {
            self.propertiesManager?.setSource([.camera, .audio])
        }
    }
    
    @objc func selectScreen(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == sender.itemArray.count-1 {
            self.viewDelegate?.openPartOfScreenPicker()
        } else {
            let index = sender.indexOfSelectedItem
            self.propertiesManager?.setCurrentScreen(NSScreen.screens[index])
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
//        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? NSArray else { return }
//        print(windowList)
        self.isRecording = !self.isRecording
        self.viewDelegate?.beginRecording()
        self.startRecordingButton.title = self.isRecording ? "End Recording!" : "Start Recording..."
        if self.isRecording {
            KORecordingCoordinator.sharedInstance.beginRecording()
        } else {
            KORecordingCoordinator.sharedInstance.endRecording()
        }
    }
    
    func setMouseHighlighterCheckbox() {
        mouseHighlighterOption.setButtonType(.switch)
        
        self.view.addSubview(mouseHighlighterOption)
        mouseHighlighterOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mouseHighlighterOption.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            mouseHighlighterOption.topAnchor.constraint(equalTo: self.startRecordingButton.bottomAnchor, constant: 24)
        ])
    }
    
    func setMirroredCheckbox() {
        self.mirroredOption.setButtonType(.switch)
        
        self.view.addSubview(self.mirroredOption)
        self.mirroredOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mirroredOption.leadingAnchor.constraint(equalTo: self.mouseHighlighterOption.leadingAnchor),
            mirroredOption.topAnchor.constraint(equalTo: self.mouseHighlighterOption.bottomAnchor, constant: 12)
        ])
    }
    
    @objc func toggleMouseHighlighter(sender: NSButton) {
        self.propertiesManager?.setCaptureMouseClick(sender.state == .on ? true : false)
    }
    
    @objc func toggleMirror(sender: NSButton) {
        self.propertiesManager?.setIsMirrored(sender.state == .on ? true : false)
    }
    
    func setProperties() {
        self.mouseHighlighterOption.state = self.propertiesManager?.shouldCaptureMouseClick() == true ? .on : .off
        self.mirroredOption.state = self.propertiesManager?.getIsMirrored() == true ? .on : .off
    }
}
