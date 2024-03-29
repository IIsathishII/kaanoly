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

class KOHomeViewController : NSViewController {

    weak var propertiesManager : KOPropertiesDataManager? {
        didSet {
            self.setSourceState()
            self.setAdvancedMenuItemStates()
            self.setLocationState()
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
    
    var recordButton : NSButton = {
        let button = NSButton.init()
        button.image = NSImage.init(named: "Record")!
        button.setButtonType(.momentaryChange)
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
        button.image = NSImage.init(named: "Directory_unselected")!
        button.imagePosition = .imageOnly
        return button
    }()
    var locationLabel : NSTextField = {
        let label = NSTextField.init(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: 9, weight: .light)
        label.alignment = .center
        return label
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
    
    func setSourceState() {
        if let source = self.propertiesManager?.getSource() {
            self.screenButton.state = source.contains(.screen) ? .on : .off
            self.cameraButton.state = source.contains(.camera) ? .on : .off
            self.audioButton.state = source.contains(.audio) ? .on : .off
            
            self.screenDropDown.isEnabled = self.screenButton.state == .on
            self.videoDropDown.isEnabled = self.cameraButton.state == .on
            self.audioDropDown.isEnabled = self.audioButton.state == .on
        }
        self.screenButton.isClickNotAllowed = self.cameraButton.state == .off && self.screenButton.state == .on
        self.cameraButton.isClickNotAllowed = self.screenButton.state == .off && self.cameraButton.state == .on
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
        
        self.locationLabel.usesSingleLineMode = false
        self.locationLabel.maximumNumberOfLines = 2
        self.locationLabel.cell?.wraps = true
        
        locationMenu = NSMenu.init()
        locationMenu.delegate = self
        
        self.view.addSubview(self.locationButton)
        self.view.addSubview(self.locationLabel)
        self.locationButton.translatesAutoresizingMaskIntoConstraints = false
        self.locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationButton.centerYAnchor.constraint(equalTo: self.recordButton.centerYAnchor),
            self.locationButton.trailingAnchor.constraint(equalTo: self.recordButton.leadingAnchor, constant: -40),
            self.locationButton.widthAnchor.constraint(equalToConstant: 36),
            self.locationButton.heightAnchor.constraint(equalToConstant: 36),
            
            self.locationLabel.leadingAnchor.constraint(equalTo: self.locationButton.leadingAnchor, constant: -12),
            self.locationLabel.trailingAnchor.constraint(equalTo: self.locationButton.trailingAnchor, constant: 12),
            self.locationLabel.topAnchor.constraint(equalTo: self.locationButton.bottomAnchor, constant: 2)
        ])
    }
    
    @objc func selectLocalStorage() {
        let openPanel = NSOpenPanel.init()
        openPanel.canCreateDirectories = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        self.viewDelegate?.didOpenDirectoryPanel()
        let response = openPanel.runModal()
        self.viewDelegate?.didCloseDirectoryPanel()
        if let directory = openPanel.url {
            self.propertiesManager?.setStorageDirectory(openPanel.url!)
            self.setLocationState()
        }
    }
    
    func setLocationState() {
        if self.propertiesManager?.getStorageDirectory() != nil {
            self.locationButton.image = NSImage.init(named: "Directory")
            self.locationLabel.stringValue = "\(self.propertiesManager!.getStorageDirectory()!.lastPathComponent)"
        } else {
            self.locationButton.image = NSImage.init(named: "Directory_unselected")
            self.locationLabel.stringValue = "Select a storage location"
        }
    }
    
    func isStorageLocationAvailable() -> Bool {
        if let url = self.propertiesManager?.getStorageDirectory() {
            return true
        }
        return false
    }
    
    @objc func beginRecording() {
        if let source = self.propertiesManager?.getSource() {
            var permissionForScreen = true
            var permissionForCamera = true
            var permissionForAudio = true
            if source.contains(.screen) && !CGRequestScreenCaptureAccess() {
                permissionForScreen = false
            }
            if source.contains(.camera) && AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                permissionForCamera = false
            }
            if source.contains(.audio) && AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
                permissionForAudio = false
            }
            if !permissionForCamera || !permissionForScreen || !permissionForAudio {
                let alert = NSAlert.init()
                alert.addButton(withTitle: "Ok")
                alert.messageText = "Allow access to the selected sources to begin recording"
                alert.informativeText = "Go to System Preferences -> Security & Privacy -> Privacy to grant the permissions"
                self.viewDelegate?.didOpenDirectoryPanel()
                alert.runModal()
                self.viewDelegate?.didCloseDirectoryPanel()
                return
            }
            if source.contains(.audio) && !source.contains(.camera) && !source.contains(.screen) {
                let alert = NSAlert.init()
                alert.addButton(withTitle: "Ok")
                alert.messageText = "Please select a video recording source(Screen/Camera)"
                self.viewDelegate?.didOpenDirectoryPanel()
                alert.runModal()
                self.viewDelegate?.didCloseDirectoryPanel()
                return
            }
        }
        if !self.isStorageLocationAvailable() {
            self.viewDelegate?.didOpenDirectoryPanel()
            let alert = NSAlert.init()
            alert.messageText = "Please Select a storage location to begin recording"
            alert.runModal()
            self.viewDelegate?.didCloseDirectoryPanel()
            self.didSelectDirectoryButton()
            return
        }
        self.isRecording = !self.isRecording
        self.viewDelegate?.beginRecording {
            if self.isRecording {
                KORecordingCoordinator.sharedInstance.beginRecording()
            } else {
                KORecordingCoordinator.sharedInstance.endRecording()
            }
        }
    }
    
    func checkPermissionFor(Source source: KOMediaSettings.MediaSource) -> Bool {
        var isAuthorized = true
        var messageText = ""
        if source == .camera {
            messageText = "Allow access to the camera"
            isAuthorized = !(AVCaptureDevice.authorizationStatus(for: .video) != .authorized)
        } else if source == .screen {
            messageText = "Allow access to the screen"
            isAuthorized = CGRequestScreenCaptureAccess()
        } else {
            messageText = "Allow access to the microphone"
            isAuthorized = !(AVCaptureDevice.authorizationStatus(for: .audio) != .authorized)
        }
        if !isAuthorized {
            let alert = NSAlert.init()
            alert.addButton(withTitle: "Ok")
            alert.messageText = messageText
            alert.informativeText = "Go to System Preferences -> Security & Privacy -> Privacy to grant the permissions"
            self.viewDelegate?.didOpenDirectoryPanel()
            alert.runModal()
            self.viewDelegate?.didCloseDirectoryPanel()
            return true
        }
        return false
    }
    
    @objc func screenSelected() {
        if self.checkPermissionFor(Source: .screen) {
            self.screenButton.state = .off
            return
        }
        self.cameraButton.isClickNotAllowed = self.screenButton.state == .off
        self.screenDropDown.isEnabled = (self.screenButton.state == .on)
        self.changeSource()
    }
    
    @objc func cameraSelected() {
        if self.checkPermissionFor(Source: .camera) {
            self.cameraButton.state = .off
            return
        }
        self.screenButton.isClickNotAllowed = self.cameraButton.state == .off
        self.videoDropDown.isEnabled = (self.cameraButton.state == .on)
        self.changeSource()
    }
    
    @objc func audioSelected() {
        if self.checkPermissionFor(Source: .audio) {
            self.audioButton.state = .off
            return
        }
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
            self.propertiesManager?.removeCroppedRect()
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
        if self.propertiesManager?.getStorageDirectory() == nil {
            self.selectLocalStorage()
        } else {
            locationMenu.popUp(positioning: nil, at: NSPoint.init(x: 0, y: self.locationButton.bounds.height), in: self.locationButton)
        }
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

extension KOHomeViewController : NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        
        var item : NSMenuItem
        if let directory = self.propertiesManager?.getStorageDirectory() {
            item = NSMenuItem.init(title: directory.path, action: nil, keyEquivalent: "")
            item.state = .on
            menu.addItem(item)
        }
        item = NSMenuItem.init(title: "Select a directory", action: #selector(selectLocalStorage), keyEquivalent: "")
        item.target = self
        menu.addItem(item)
    }
}
