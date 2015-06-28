//
//  AppDelegate.swift
//  amplify
//
//  Created by Ezra Zigmond on 6/28/15.
//  Copyright (c) 2015 Ezra Zigmond. All rights reserved.
//

import Cocoa
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusIcon")
        icon!.setTemplate(true)
        
        statusItem.image = icon
        statusItem.menu = statusMenu
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func playClicked(sender: NSMenuItem) {
        if (sender.state == NSOffState) {
            sender.title = "Pause ❙❙"
            sender.state = NSOnState
        } else {
            sender.title = "Play ▶️"
            sender.state = NSOffState
        }
    }
    
    @IBAction func nextClicked(sender: NSMenuItem) {
        
    }
    
    @IBAction func prevClicked(sender: NSMenuItem) {
        
    }
}

