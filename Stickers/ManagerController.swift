//
//  WindowController.swift
//  Stickers
//
//  Created by Timothy Park on 4/17/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class ManagerController: NSWindowController, NSToolbarDelegate {
    
    var toolbar: Toolbar!
    
    convenience init() {
        let mainController = SplitViewController(nibName: nil, bundle: nil)
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 400), styleMask: [.titled, .closable, .resizable, .miniaturizable, .unifiedTitleAndToolbar], backing: .buffered, defer: true)
        win.level = .normal
        win.contentViewController = mainController
        win.isMovableByWindowBackground = false
        win.titleVisibility = .hidden
        self.init(window: win)
        shouldCascadeWindows = false
        setupToolbar()
    }
    
    func setupToolbar() {
        toolbar = Toolbar(identifier: ToolbarIdentifiers.managerToolbar)
        toolbar.managerDelegate = self
        window?.toolbar = toolbar
    }
    
}

// MARK: - ManagerDelegate
extension ManagerController: ManagerDelegate {
    
    func deleteStickers() {
        (contentViewController as! DetailController).deleteSelectedStickers()
    }
    
}
