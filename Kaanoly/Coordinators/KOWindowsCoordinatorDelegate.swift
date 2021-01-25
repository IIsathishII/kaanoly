//
//  KOWindowsCoordinatorDelegate.swift
//  Kaanoly
//
//  Created by SathishKumar on 04/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

protocol KOWindowsCoordinatorDelegate : class {
    
    func change(Source source: KOMediaSettings.MediaSource)
    func change(Screen screen: NSScreen)
    
    func beginRecording(countDownCompletion: @escaping () -> ())
    func stopRecording()
    func pauseRecording()
    func resumeRecording()
    func cancelRecording()
    func updateRecentVideosList()
    
    func openPartOfScreenPicker()
    func closePartOfScreenPicker()
    func clearPartOfScreenSelectionsInAllScreens()
    
    func stopRecordingAbruptly()
}
