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
    var timer: NSTimer!
    var precision: Int! = 0
    var precisionItems = Array<NSMenuItem>()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // initialize menu
        let menu = NSMenu()
        let menuPrecision = NSMenu()
        let menuPrecisionItem = NSMenuItem(title: "Precision", action: nil, keyEquivalent: "")
        menuPrecisionItem.submenu = menuPrecision
        
        0.stride(to: 4, by: 1).forEach { (num: Int) -> () in
            precisionItems.append(NSMenuItem(title: String(num), action: "setPrecision:", keyEquivalent: ""))
        }
        precisionItems.first!.state = NSOnState
        
        precisionItems.forEach { (item: NSMenuItem) -> () in
            menuPrecision.addItem(item)
        }
        
        menu.addItem(menuPrecisionItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: "q"))
        
        // initialize statusItem
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.title = "@000"
        statusItem.menu = menu
        
        // initialize update timer and add it to the run loop
        timer = NSTimer(timeInterval: 1, target: self, selector: "update", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        update()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        timer.invalidate()
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
    }
    
    func calculateBeats(aDate: NSDate) -> Double {
        // this feels really hack-ish
        let fmt = NSDateFormatter()
        fmt.timeZone = NSTimeZone(name: "UTC")
        fmt.dateFormat = "HH"
        let hours = (Int(fmt.stringFromDate(aDate))! + 1) % 24
        fmt.dateFormat = "mm"
        let minutes = Int(fmt.stringFromDate(aDate))!
        fmt.dateFormat = "ss"
        let seconds = Int(fmt.stringFromDate(aDate))!
        return Double(seconds + (minutes * 60) + (hours * 3600)) / 86.4
    }
    
    func update() {
        let beats = calculateBeats(NSDate())
        statusItem.title = NSString(format: "@%.*f", precision, beats) as String
    }
    
    func setPrecision(sender: NSMenuItem) {
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
    NSApplication.sharedApplication().delegate = ad
    NSApplication.sharedApplication().run()
}
