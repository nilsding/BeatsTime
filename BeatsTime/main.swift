//
//  main.swift
//  BeatsTime
//
//  Created by Georg G. on 07/01/16.
//  Copyright © 2016 nilsding.  Licensed under MIT license.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var timer: Timer!
    var precision: Int! = 0
    var precisionItems = Array<NSMenuItem>()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // initialize menu
        let menu = NSMenu()
        let menuPrecision = NSMenu()
        let menuPrecisionItem = NSMenuItem(title: "Precision", action: nil, keyEquivalent: "")
        menuPrecisionItem.submenu = menuPrecision
        
        stride(from: 0, to: 4, by: 1).forEach { (num: Int) -> () in
            precisionItems.append(NSMenuItem(title: String(num), action: #selector(AppDelegate.setPrecision(_:)), keyEquivalent: ""))
        }
        precisionItems.first!.state = NSOnState
        
        precisionItems.forEach { (item: NSMenuItem) -> () in
            menuPrecision.addItem(item)
        }
        
        menu.addItem(menuPrecisionItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared().terminate(_:)), keyEquivalent: "q"))
        
        // initialize statusItem
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem.title = "@000"
        statusItem.menu = menu
        
        // initialize update timer and add it to the run loop
        timer = Timer(timeInterval: 1, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        update()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        timer.invalidate()
        NSStatusBar.system().removeStatusItem(statusItem)
    }
    
    func calculateBeats(_ aDate: Date) -> Double {
        // this feels really hack-ish
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone(identifier: "UTC")
        fmt.dateFormat = "HH"
        let hours = (Int(fmt.string(from: aDate))! + 1) % 24
        fmt.dateFormat = "mm"
        let minutes = Int(fmt.string(from: aDate))!
        fmt.dateFormat = "ss"
        let seconds = Int(fmt.string(from: aDate))!
        return Double(seconds + (minutes * 60) + (hours * 3600)) / 86.4
    }
    
    func update() {
        let beats = calculateBeats(Date())
        statusItem.title = NSString(format: "@%.*f", precision, beats) as String
    }
    
    func setPrecision(_ sender: NSMenuItem) {
        precision = Int(sender.title)
        precisionItems.forEach { (item: NSMenuItem) -> () in
            item.state = NSOffState
        }
        sender.state = NSOnState
        update()
    }
}

autoreleasepool {
    let ad = AppDelegate()
    NSApplication.shared().delegate = ad
    NSApplication.shared().run()
}
