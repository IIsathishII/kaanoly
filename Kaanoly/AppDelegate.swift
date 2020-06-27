//
//  AppDelegate.swift
//  Kaanoly
//
//  Created by SathishKumar on 31/05/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var coordinator : KOWindowsCoordinator!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        coordinator = KOWindowsCoordinator.init()
        NSApp.presentationOptions = [.autoHideDock]
        NSApp.setActivationPolicy(.accessory)
        NSRunningApplication.current.activate(options: .activateAllWindows)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

