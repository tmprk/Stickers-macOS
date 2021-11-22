//
//  ImportController.swift
//  Stickers
//
//  Created by Timothy Park on 7/17/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class ImportController: NSWindowController, NSToolbarDelegate, NSWindowDelegate {
    
    var toolbar: Toolbar!
    
    convenience init() {
        let mainController = ImportViewController(nibName: nil, bundle: nil)
        let overlayWindow = NSWindow(contentViewController: mainController)
        overlayWindow.level = .normal
        overlayWindow.styleMask = [.titled, .miniaturizable, .resizable, .closable]
        self.init(window: overlayWindow)
        shouldCascadeWindows = false
        window?.delegate = self
        window?.title = "New Sticker"
        setupToolbar()
    }
    
    func setupToolbar() {
        toolbar = Toolbar(identifier: ToolbarIdentifiers.preferencesToolbar)
        toolbar.mainDelegate = self
        
        if #available(macOS 11.0, *) {
            window?.toolbarStyle = .unified
        }
        
        window?.toolbar = toolbar
    }
    
    func windowWillClose(_ notification: Notification) {
        (contentViewController as! ImportViewController).viewWindowCloses()
    }
    
}

// MARK: - ToolbarDelegate
extension ImportController: CanvasDelegate {
    
    func resetMask() {
        (contentViewController as! ImportViewController).resetLayers()
    }
    
    func activateMode(index: Int) {
        (contentViewController as! ImportViewController).setMode(mode: DrawMode(rawValue: index)!)
    }
    
    func setBorderColor(color: NSColor) {
        (contentViewController as! ImportViewController).color = color
    }
    
    func setBorderWidth(width: CGFloat) {
        (contentViewController as! ImportViewController).width = width
    }
    
    func showSavePanel() {
        (contentViewController as! ImportViewController).presentSaveAlert()
    }
    
}
