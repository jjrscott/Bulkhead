//
//  AppDelegate.swift
//  Bulkhead
//
//  Created by John Scott on 24/08/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

import Cocoa
import os.log

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        NSAppleEventManager.shared().setEventHandler(self,
//                                                     andSelector: #selector(handle(event:replyEvent:)),
//                                                     forEventClass: AEEventClass(kCoreEventClass),
//                                                     andEventID: AEEventID(kAEOpenDocuments))
//
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    @objc func handle(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        os_log("%@", event?.description ?? "")
        guard let event = event,
            event.eventClass == AEEventClass(kCoreEventClass) && event.eventID == AEEventID(kAEOpenDocuments) else {
                return
        }

//        guard let additionalEventParamDescriptor = event.paramDescriptor(forKeyword: keyAEPropData) else {
//            return
//        }
//
//
//        guard let directObject = additionalEventParamDescriptor.paramDescriptor(forKeyword: keyDirectObject) else {
//            return
//        }

//        print(directObject)

    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        return .terminateNow
    }
}

