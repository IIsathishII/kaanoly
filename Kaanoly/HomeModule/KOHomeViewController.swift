//
//  KOHomeViewController.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit
import IOKit
import AVFoundation

//class KOHomeViewController : NSViewController {
//
//    var startRecordingButton = NSButton.init()
//    var isRecording = false
//    var mouseHighlighterOption = NSButton.init(title: "Enable Mouse Highlighter", target: self, action: #selector(toggleMouseHighlighter))
//    var mirroredOption = NSButton.init(title: "Mirror Video", target: self, action: #selector(toggleMirror))
//
//    var openButton = NSButton.init(title: " Open Location... ", target: self, action: #selector(selectFolderLocation))
//    var sourceList = NSPopUpButton.init(frame: .zero, pullsDown: false)
//
//    weak var propertiesManager : KOPropertiesDataManager? {
//        didSet {
//            self.setProperties()
//        }
//    }
//
//    weak var viewDelegate : KOWindowsCoordinatorDelegate?
//
//    override func loadView() {
//        self.view = NSView.init()
//    }
//
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        self.preferredContentSize = NSSize.init(width: 400, height: 300)
//        self.setOpenButton()
//        self.setSourcePopup()
//        self.setScreenPopup()
//        self.setRecordingButton()
//        self.setMouseHighlighterCheckbox()
//        self.setMirroredCheckbox()
//    }
//
//    @objc func selectFolderLocation() {
//        let openPanel = NSOpenPanel.init()
//        openPanel.canCreateDirectories = true
//        openPanel.canChooseDirectories = true
//        openPanel.canChooseFiles = false
////        openPanel.level = self.view.window!.level
//        let response = openPanel.runModal()
//        self.propertiesManager?.setStorageDirectory(openPanel.url!)
//        print("Response :::: ", response)
//    }
//
//    func setOpenButton() {
//        openButton.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(openButton)
//        NSLayoutConstraint.activate([
//            openButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
//            openButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24)
//        ])
//    }
//
//    func setSourcePopup() {
//        sourceList.target = self
//        sourceList.action = #selector(selectSource(_:))
//        sourceList.addItems(withTitles: ["Camera+Screen", "Screen", "Camera"])
//        self.view.addSubview(sourceList)
//        sourceList.translatesAutoresizingMaskIntoConstraints = false
//        var newConstraints = [NSLayoutConstraint]()
//        newConstraints.append(sourceList.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24))
//        newConstraints.append(sourceList.topAnchor.constraint(equalTo: self.openButton.bottomAnchor, constant: 18))
//        NSLayoutConstraint.activate(newConstraints)
//    }
//
//    func setScreenPopup() {
//        var screenList = NSPopUpButton.init(frame: .zero, pullsDown: false)
//        screenList.target = self
//        screenList.action = #selector(selectScreen(_:))
//        var screenNames = [String]()
//        for i in 0..<NSScreen.screens.count {
//            screenNames.append("Screen \(i+1)" + (NSScreen.screens[i].getDeviceName() != nil ? " (\(NSScreen.screens[i].getDeviceName()!))" : ""))
//        }
//        screenList.addItems(withTitles: screenNames)
//        screenList.addItem(withTitle: "Part of Screen")
//        self.view.addSubview(screenList)
//        screenList.translatesAutoresizingMaskIntoConstraints = false
//        var newConstraints = [NSLayoutConstraint]()
//        newConstraints.append(screenList.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24))
//        newConstraints.append(screenList.topAnchor.constraint(equalTo: self.sourceList.bottomAnchor, constant: 18))
//        NSLayoutConstraint.activate(newConstraints)
//    }
//
//    @objc func selectSource(_ sender: NSPopUpButton) {
//        let index = sender.indexOfSelectedItem
//        if index == 0 {
//            self.propertiesManager?.setSource([.camera, .screen, .audio])
//        } else if index == 1 {
//            self.propertiesManager?.setSource([.screen, .audio])
//        } else if index == 2 {
//            self.propertiesManager?.setSource([.camera, .audio])
//        }
//    }
//
//    @objc func selectScreen(_ sender: NSPopUpButton) {
//        if sender.indexOfSelectedItem == sender.itemArray.count-1 {
//            self.viewDelegate?.openPartOfScreenPicker()
//        } else {
//            let index = sender.indexOfSelectedItem
//            self.propertiesManager?.setCropped(Rect: nil, displayId: NSScreen.screens[index].getScreenNumber()!)
//            self.propertiesManager?.setCurrentScreen(NSScreen.screens[index])
//        }
//    }
//
//    func setRecordingButton() {
//        self.startRecordingButton.bezelStyle = .rounded
//        self.startRecordingButton.title = "Start Recording..."
//        self.startRecordingButton.target = self
//        self.startRecordingButton.action = #selector(beginRecording)
//
//        self.view.addSubview(self.startRecordingButton)
//        self.startRecordingButton.translatesAutoresizingMaskIntoConstraints = false
//        var recordingButtonConstraints = [NSLayoutConstraint]()
//        recordingButtonConstraints.append(self.startRecordingButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
//        recordingButtonConstraints.append(self.startRecordingButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor))
//        NSLayoutConstraint.activate(recordingButtonConstraints)
//    }
//
//    @objc func beginRecording() {
////        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? NSArray else { return }
////        print(windowList)
//        self.isRecording = !self.isRecording
//        self.viewDelegate?.beginRecording()
//        self.startRecordingButton.title = self.isRecording ? "End Recording!" : "Start Recording..."
//        if self.isRecording {
//            KORecordingCoordinator.sharedInstance.beginRecording()
//        } else {
//            KORecordingCoordinator.sharedInstance.endRecording()
//        }
//    }
//
//    func setMouseHighlighterCheckbox() {
//        mouseHighlighterOption.setButtonType(.switch)
//
//        self.view.addSubview(mouseHighlighterOption)
//        mouseHighlighterOption.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            mouseHighlighterOption.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
//            mouseHighlighterOption.topAnchor.constraint(equalTo: self.startRecordingButton.bottomAnchor, constant: 24)
//        ])
//    }
//
//    func setMirroredCheckbox() {
//        self.mirroredOption.setButtonType(.switch)
//
//        self.view.addSubview(self.mirroredOption)
//        self.mirroredOption.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            mirroredOption.leadingAnchor.constraint(equalTo: self.mouseHighlighterOption.leadingAnchor),
//            mirroredOption.topAnchor.constraint(equalTo: self.mouseHighlighterOption.bottomAnchor, constant: 12)
//        ])
//    }
//
//    @objc func toggleMouseHighlighter(sender: NSButton) {
//        self.propertiesManager?.setCaptureMouseClick(sender.state == .on ? true : false)
//    }
//
//    @objc func toggleMirror(sender: NSButton) {
//        self.propertiesManager?.setIsMirrored(sender.state == .on ? true : false)
//    }
//
//    func setProperties() {
//        self.mouseHighlighterOption.state = self.propertiesManager?.shouldCaptureMouseClick() == true ? .on : .off
//        self.mirroredOption.state = self.propertiesManager?.getIsMirrored() == true ? .on : .off
//    }
//}

class KOHomeViewController : NSViewController {

    weak var propertiesManager : KOPropertiesDataManager? {
        didSet {
            self.setAdvancedMenuItemStates()
        }
    }

    weak var viewDelegate : KOWindowsCoordinatorDelegate?
    var isRecording = false
    
    var screenButton = KOHomeLargeIcon.init()
    var cameraButton = KOHomeLargeIcon.init()
    var audioButton = KOHomeLargeIcon.init()
    
    var screenLabel = NSTextField.init(labelWithString: "Screen")
    var screenDropDown = KOHomeDropDownButton.init()
    
    var videoLabel = NSTextField.init(labelWithString: "Video")
    var videoDropDown = KOHomeDropDownButton.init()
    var selectedVideoSource = 0
    var videoList : [AVCaptureDevice] = {
        var list = [AVCaptureDevice]()
        let session = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.externalUnknown, .builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        list = session.devices
        return list
    }()
    
    var audioLabel = NSTextField.init(labelWithString: "Audio")
    var audioDropDown = KOHomeDropDownButton.init()
    var selectedAudioSource = 0
    var audioList : [AVCaptureDevice] = {
        var list = [AVCaptureDevice]()
        let session = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInMicrophone, .externalUnknown], mediaType: .audio, position: .unspecified)
        list = session.devices
        return list
    }()
    
    var recordButton : KORecordButton = {
        let button = KORecordButton.init()
        button.image = NSImage.init(named: "Record")!
        button.imagePosition = .imageOnly
        button.isBordered = false
        return button
    }()
    
    var advancedButton : NSButton = {
        let button = NSButton.init()
        button.setButtonType(.momentaryChange)
        button.isBordered = false
        button.imagePosition = .imageOnly
        button.image = NSImage.init(named: "Advanced")!
        return button
    }()
    var advancedMenu = NSMenu.init()
    
    var locationButton : NSButton = {
        let button = NSButton.init()
        button.setButtonType(.momentaryChange)
        button.isBordered = false
        button.image = NSImage.init(named: "Directory")!
        button.imagePosition = .imageOnly
        return button
    }()
    var locationMenu = NSMenu.init()

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
        super.viewDidLoad()
        self.preferredContentSize = NSSize.init(width: 350, height: 400)
        self.setSourceButtons()
        self.setScreenDropDown()
        self.setVideoDropDown()
        self.setAudioDropDown()
        self.setRecordButton()
        self.setAdvancedButton()
        self.setLocationButton()
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenChange(_:)), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
    
    func setSourceButtons() {
        self.screenButton.image = NSImage.init(named: "Screen")
        self.cameraButton.image = NSImage.init(named: "Camera")
        self.audioButton.image = NSImage.init(named: "Mic")
        
        self.screenButton.state = .on
        self.cameraButton.state = .on
        self.audioButton.state = .on
        
        self.screenButton.target = self
        self.screenButton.action = #selector(screenSelected)
        self.cameraButton.target = self
        self.cameraButton.action = #selector(cameraSelected)
        self.audioButton.target = self
        self.audioButton.action = #selector(audioSelected)
        
        self.view.addSubview(self.screenButton)
        self.view.addSubview(self.cameraButton)
        self.view.addSubview(self.audioButton)
        self.screenButton.translatesAutoresizingMaskIntoConstraints = false
        self.cameraButton.translatesAutoresizingMaskIntoConstraints = false
        self.audioButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.screenButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 55),
            self.screenButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 21),
            self.screenButton.widthAnchor.constraint(equalToConstant: 56),
            self.screenButton.heightAnchor.constraint(equalToConstant: 56),
            
            self.cameraButton.leadingAnchor.constraint(equalTo: self.screenButton.trailingAnchor, constant: 36),
            self.cameraButton.topAnchor.constraint(equalTo: self.screenButton.topAnchor),
            self.cameraButton.widthAnchor.constraint(equalToConstant: 56),
            self.cameraButton.heightAnchor.constraint(equalToConstant: 56),
            
            self.audioButton.leadingAnchor.constraint(equalTo: self.cameraButton.trailingAnchor, constant: 36),
            self.audioButton.topAnchor.constraint(equalTo: self.screenButton.topAnchor),
            self.audioButton.widthAnchor.constraint(equalToConstant: 56),
            self.audioButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    func setScreenDropDownMenu() {
        var screenList = NSMenu.init()
        var screenNames = [String]()
        for i in 0..<NSScreen.screens.count {
            screenNames.append("Screen \(i+1)" + (NSScreen.screens[i].getDeviceName() != nil ? " (\(NSScreen.screens[i].getDeviceName()!))" : ""))
            let item = NSMenuItem.init(title: screenNames[i], action: nil, keyEquivalent: "")
            if i == 0 {
                item.state = .on
            }
            item.tag = i+1
            item.target = self
            item.action = #selector(didSelectScreenSource(_:))
            screenList.addItem(item)
        }
        let item = NSMenuItem.init(title: "Part of Screen", action: nil, keyEquivalent: "")
        item.tag = NSScreen.screens.count+1
        item.target = self
        item.action = #selector(didSelectScreenSource(_:))
        screenList.addItem(item)
        self.screenDropDown.title = screenNames[0]
        self.screenDropDown.menu = screenList
    }
    
    @objc func handleScreenChange(_ notification: Notification) {
        self.screenDropDown.menu?.cancelTracking()
        self.setScreenDropDownMenu()
    }
    
    func setScreenDropDown() {
        self.setScreenDropDownMenu()
        
        self.view.addSubview(self.screenLabel)
        self.screenLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.screenDropDown)
        self.screenDropDown.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.screenLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.screenLabel.topAnchor.constraint(equalTo: self.audioButton.bottomAnchor, constant: 20),
            self.screenLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            
            self.screenDropDown.leadingAnchor.constraint(equalTo: self.screenLabel.leadingAnchor),
            self.screenDropDown.topAnchor.constraint(equalTo: self.screenLabel.bottomAnchor, constant: 8),
            self.screenDropDown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.screenDropDown.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setVideoDropDown() {
        let videoMenu = NSMenu.init()
        var tag = 1
        for device in self.videoList {
            let item = NSMenuItem.init(title: device.localizedName, action: nil, keyEquivalent: "")
            item.tag = tag
            item.target = self
            item.action = #selector(didSelectVideoSource(_:))
            if AVCaptureDevice.default(for: .video)!.localizedName == device.localizedName {
                item.state = .on
                self.selectedVideoSource = tag
            }
            videoMenu.addItem(item)
            tag += 1
        }
        self.videoDropDown.menu = videoMenu
        self.videoDropDown.title = AVCaptureDevice.default(for: .video)!.localizedName
        
        self.view.addSubview(self.videoLabel)
        self.videoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.videoDropDown)
        self.videoDropDown.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.videoLabel.leadingAnchor.constraint(equalTo: self.screenLabel.leadingAnchor),
            self.videoLabel.topAnchor.constraint(equalTo: self.screenDropDown.bottomAnchor, constant: 8),
            self.videoLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            
            self.videoDropDown.leadingAnchor.constraint(equalTo: self.videoLabel.leadingAnchor),
            self.videoDropDown.topAnchor.constraint(equalTo: self.videoLabel.bottomAnchor, constant: 8),
            self.videoDropDown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.videoDropDown.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setAudioDropDown() {
        let audioMenu = NSMenu.init()
        var tag = 1
        for device in self.audioList {
            let item = NSMenuItem.init(title: device.localizedName, action: nil, keyEquivalent: "")
            item.tag = tag
            item.target = self
            item.action = #selector(didSelectAudioSource(_:))
            if AVCaptureDevice.default(for: .audio)!.localizedName == device.localizedName {
                item.state = .on
                self.selectedAudioSource = tag
            }
            audioMenu.addItem(item)
            tag += 1
        }
        self.audioDropDown.menu = audioMenu
        self.audioDropDown.title = AVCaptureDevice.default(for: .audio)!.localizedName
        
        self.view.addSubview(self.audioLabel)
        self.audioLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.audioDropDown)
        self.audioDropDown.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.audioLabel.leadingAnchor.constraint(equalTo: self.screenLabel.leadingAnchor),
            self.audioLabel.topAnchor.constraint(equalTo: self.videoDropDown.bottomAnchor, constant: 8),
            self.audioLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            
            self.audioDropDown.leadingAnchor.constraint(equalTo: self.audioLabel.leadingAnchor),
            self.audioDropDown.topAnchor.constraint(equalTo: self.audioLabel.bottomAnchor, constant: 8),
            self.audioDropDown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.audioDropDown.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setRecordButton() {
        self.recordButton.target = self
        self.recordButton.action = #selector(beginRecording)
        
        self.view.addSubview(self.recordButton)
        self.recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.recordButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -25),
//            self.recordButton.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -62.5),
            self.recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.recordButton.widthAnchor.constraint(equalToConstant: 75),
            self.recordButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func setAdvancedButton() {
        self.advancedButton.target = self
        self.advancedButton.action  = #selector(showAdvancedMenu)
        
        advancedMenu = NSMenu.init()
        var item = NSMenuItem.init(title: "Highlight mouse click", action: #selector(toggleHighlightMouseClick(_:)), keyEquivalent: "")
        item.target = self
        advancedMenu.addItem(item)
        item = NSMenuItem.init(title: "Mirror camera", action: #selector(toggleMirrorCamera(_:)), keyEquivalent: "")
        item.target = self
        advancedMenu.addItem(item)

        self.view.addSubview(self.advancedButton)
        self.advancedButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.advancedButton.centerYAnchor.constraint(equalTo: self.recordButton.centerYAnchor),
            self.advancedButton.leadingAnchor.constraint(equalTo: self.recordButton.trailingAnchor, constant: 40),
            self.advancedButton.widthAnchor.constraint(equalToConstant: 36),
            self.advancedButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func setAdvancedMenuItemStates() {
        for item in self.advancedMenu.items {
            if item.action == #selector(toggleHighlightMouseClick(_:)) {
                item.state = self.propertiesManager?.shouldCaptureMouseClick() == true ? .on : .off
            } else if item.action == #selector(toggleMirrorCamera(_:)) {
                item.state = self.propertiesManager?.getIsMirrored() == true ? .on : .off
            }
        }
    }
    
    func setLocationButton() {
        self.locationButton.target = self
        self.locationButton.action  = #selector(didSelectDirectoryButton)
        
        locationMenu = NSMenu.init()
        var item = NSMenuItem.init(title: "Select a directory", action: nil, keyEquivalent: "")
        locationMenu.addItem(item)
        item = NSMenuItem.init(title: "iCloud", action: nil, keyEquivalent: "")
        locationMenu.addItem(item)
        
        self.view.addSubview(self.locationButton)
        self.locationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationButton.centerYAnchor.constraint(equalTo: self.recordButton.centerYAnchor),
            self.locationButton.trailingAnchor.constraint(equalTo: self.recordButton.leadingAnchor, constant: -40),
            self.locationButton.widthAnchor.constraint(equalToConstant: 36),
            self.locationButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc func beginRecording() {
        self.isRecording = !self.isRecording
        self.viewDelegate?.beginRecording {
            if self.isRecording {
                KORecordingCoordinator.sharedInstance.beginRecording()
            } else {
                KORecordingCoordinator.sharedInstance.endRecording()
            }
        }
    }
    
    @objc func screenSelected() {
        self.cameraButton.isClickNotAllowed = self.screenButton.state == .off
        self.screenDropDown.isEnabled = (self.screenButton.state == .on)
        self.changeSource()
    }
    
    @objc func cameraSelected() {
        self.screenButton.isClickNotAllowed = self.cameraButton.state == .off
        self.videoDropDown.isEnabled = (self.cameraButton.state == .on)
        self.changeSource()
    }
    
    @objc func audioSelected() {
        self.audioDropDown.isEnabled = (self.audioButton.state == .on)
        self.changeSource()
    }
    
    func changeSource() {
        var sources : KOMediaSettings.MediaSource = []
        if self.screenButton.state == .on { sources.insert(.screen) }
        if self.cameraButton.state == .on { sources.insert(.camera) }
        if self.audioButton.state == .on { sources.insert(.audio) }
        self.propertiesManager?.setSource(sources)
    }
    
    @objc func didSelectScreenSource(_ item: NSMenuItem) {
        for item in self.screenDropDown.menu!.items {
            item.state = .off
        }
        item.state = .on
        self.screenDropDown.title = item.title
        if item.tag == self.screenDropDown.menu?.items.count {
            self.viewDelegate?.openPartOfScreenPicker()
        } else {
            self.propertiesManager?.setCropped(Rect: nil, displayId: NSScreen.screens[item.tag-1].getScreenNumber()!)
            self.propertiesManager?.setCurrentScreen(NSScreen.screens[item.tag-1])
        }
    }
    
    @objc func didSelectVideoSource(_ item: NSMenuItem) {
        self.videoDropDown.menu?.items[self.selectedVideoSource-1].state = .off
        self.selectedVideoSource = item.tag
        item.state = .on
        self.videoDropDown.title = item.title
        self.propertiesManager?.setCurrentVideo(Source: self.videoList[item.tag-1])
    }
    
    @objc func didSelectAudioSource(_ item: NSMenuItem) {
        self.audioDropDown.menu?.items[self.selectedAudioSource-1].state = .off
        self.selectedAudioSource = item.tag
        item.state = .on
        self.audioDropDown.title = item.title
        self.propertiesManager?.setCurrentAudio(Source: self.audioList[item.tag-1])
    }
    
    @objc func showAdvancedMenu() {
        advancedMenu.popUp(positioning: nil, at: NSPoint.init(x: 0, y: self.advancedButton.bounds.height), in: self.advancedButton)
    }
    
    @objc func didSelectDirectoryButton() {
        locationMenu.popUp(positioning: nil, at: NSPoint.init(x: 0, y: self.locationButton.bounds.height), in: self.locationButton)
    }
    
    @objc func toggleHighlightMouseClick(_ item : NSMenuItem) {
        item.state = item.state == .on ? .off : .on
        self.propertiesManager?.setCaptureMouseClick(item.state == .on ? true : false)
    }
    
    @objc func toggleMirrorCamera(_ item : NSMenuItem) {
        item.state = item.state == .on ? .off : .on
        self.propertiesManager?.setIsMirrored(item.state == .on ? true : false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
}

class KORecordButton : NSButton {
    
    override func mouseDown(with event: NSEvent) {
        self.image?.size = self.image?.size.applying(CGAffineTransform.init(scaleX: 0.8, y: 0.8)) ?? .zero
//        self.layer?.setAffineTransform(CGAffineTransform.init(scaleX: 0.8, y: 0.8))
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.image?.size = self.image?.size.applying(CGAffineTransform.init(scaleX: 1.25, y: 1.25)) ?? .zero
//        self.layer?.setAffineTransform(CGAffineTransform.init(scaleX: 1.25, y: 1.25))
        super.mouseUp(with: event)
    }
}
