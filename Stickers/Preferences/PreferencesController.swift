//
//  PreferencesWindowController.swift
//  Stickers
//
//  Created by Timothy Park on 7/16/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class PreferencesController: NSWindowController {
    
    convenience init() {
        let mainController = TabViewController(nibName: nil, bundle: nil)
        self.init(window: NSWindow(contentViewController: mainController))
        shouldCascadeWindows = false
        window?.titleVisibility = .hidden
        window?.backingType = .buffered
        window?.collectionBehavior = [.moveToActiveSpace]
        window?.setFrameAutosaveName("PreferencesWindow")
    }
    
}
