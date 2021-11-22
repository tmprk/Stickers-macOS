//
//  GlobalPopover.swift
//  Stickers
//
//  Created by Timothy Park on 8/19/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

// https://github.com/jtbandes/Mojo/blob/6bf35ebe626896ec0b721985736b1c4683cfe44f/Source/GlobalPopover.swift
// A popover floating on top of other content on the screen.
// It can be shown at an arbitrary position in global display space.
class GlobalPopover {
    
    private let popover = NSPopover()
    private let hostWindow = HostWindow()
    private let watcher = FrontmostApplicationWatcher.shared
    
    init(content: NSViewController) {
        popover.behavior = .transient
        popover.contentViewController = content
        NotificationCenter.default.addObserver(self, selector: #selector(popoverWillClose), name: NSPopover.willCloseNotification, object: nil)
    }
    
    func insertAndPopover() {
        guard let focusedElement = AXUIElement.systemWide.focusedUIElement else { return }
        var selectedText: AnyObject?
        let textCode = AXUIElementCopyAttributeValue(focusedElement, "AXSelectedText" as CFString, &selectedText)
        if (textCode == AXError.success) {
            // insert space
            AXUIElementSetAttributeValue(focusedElement, "AXSelectedText" as CFString, " " as CFTypeRef)
            
            var selectedRangeValue: AnyObject?
            let selectedRangeError = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue)
            
            if (selectedRangeError == .success) {
                guard let currentSelectedRange = focusedElement.selectedTextRange else { return }
                
                // select 1-length range
                var newRange = currentSelectedRange
                newRange.length = 1
                newRange.location = newRange.location - 1
                
                // let newValue = AXValueCreate(AXValueType(rawValue: kAXValueCFRangeType)!, &newRange)
                // AXUIElementSetAttributeValue(focusedElement, kAXSelectedTextRangeAttribute as CFString, newValue as CFTypeRef)
                 
                guard let afterSelectedRange = focusedElement.selectedTextRange, let bounds = focusedElement.bounds(for: CFRangeMake(newRange.location, newRange.length)) else { return }
                _ = show(from: bounds)
            }
        }
        
        // guard let focusedElement = AXUIElement.systemWide.focusedUIElement else { return }
        // var selectedText: AnyObject?
        // let textCode = AXUIElementCopyAttributeValue(focusedElement, "AXSelectedText" as CFString, &selectedText)
        // if (textCode == AXError.success) {
        //     // insert space
        //     AXUIElementSetAttributeValue(focusedElement, "AXSelectedText" as CFString, " " as CFTypeRef)
        //
        //     var selectedRangeValue: AnyObject?
        //     let selectedRangeError = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue)
        //
        //     if (selectedRangeError == .success) {
        //         guard let currentSelectedRange = focusedElement.selectedTextRange else { return }
        //
        //         // select 1-length range
        //         var newRange = currentSelectedRange
        //         newRange.length = 1
        //         newRange.location = newRange.location - 1
        //
        //         let newValue = AXValueCreate(AXValueType(rawValue: kAXValueCFRangeType)!, &newRange)
        //         AXUIElementSetAttributeValue(focusedElement, kAXSelectedTextRangeAttribute as CFString, newValue as CFTypeRef)
        //
        //         guard let afterSelectedRange = focusedElement.selectedTextRange, let bounds = focusedElement.bounds(for: afterSelectedRange) else { return }
        //         _ = show(from: bounds)
        //     }
        // }
    }
    
    func show(from rect: CGRect, preferredEdge: NSRectEdge = .minY) -> Bool {
        if popover.isShown {
            close(animated: true)
        }
        guard let hostView = hostWindow.contentView else {
            return false
        }
        
        hostWindow.setFrame(rect, display: false)
        hostWindow.orderFrontRegardless()
        popover.show(relativeTo: hostView.bounds, of: hostView, preferredEdge: preferredEdge)
        
        if let win = popover.contentViewController?.view.window as? NSPanel {
            // Allow the window to become key even if the app is not active.
            win.styleMask.insert(.nonactivatingPanel)
            win.makeKey()
            if win.isKeyWindow {
                return true
            }
        }
        close(animated: true)
        return false
    }
    
    func close(animated shouldAnimate: Bool) {
        NSApp.deactivate()
        popover.animates = shouldAnimate
        popover.performClose(self)
    }
    
    @objc func popoverWillClose(notification: Notification) {
        print("popoverWillClose")
        
        if let pid = watcher.frontmostProcessIdentifier {
            switchApp(process: pid) { (success) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    // NSApp.deactivate()
                    // strongSelf.watcher.simulateKey(0x09)
                    // FakeKey.simulateKey(0x09)
                    FakeKey.send(0x33, useCommandFlag: false)
                    // strongSelf.view.window?.close()
                    // NotificationCenter.default.post(name: NSPopover.willCloseNotification, object: nil, userInfo: ["status":true])
                }
            }
        }
    }
    
    func switchApp(process: Int32, completion: (Bool) -> ()) {
        let app = NSRunningApplication(processIdentifier: process)
        app?.activate(options: .activateIgnoringOtherApps)
        completion(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSPopover.willCloseNotification, object: nil)
    }
    
}


private class HostWindow: NSPanel {
    
    override var canBecomeKey: Bool { return true }
    
    init() {
        super.init(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        level = NSWindow.Level(Int(CGWindowLevelForKey(.mainMenuWindow)))
        hasShadow = false
        isOpaque = false
        backgroundColor = .clear
    }
    
}
