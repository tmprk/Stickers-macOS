//
//  TabViewController.swift
//  Stickers
//
//  Created by Timothy Park on 7/16/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

// https://github.com/lucasderraugh/AppleProg-Cocoa-Tutorials/blob/master/Lesson%2081/Lesson%2081/TabViewController.swift
// https://github.com/thierryH91200/Pegase/blob/33bdefecef47d437dcbcc2c2c6bb3fe92f62b1cd/Pegase/PreferencesTabViewController.swift
class TabViewController: NSTabViewController {
    
    private lazy var tabViewSizes: [String: NSSize] = [:]
    
    var vcA = SettingsViewController()
    var vcB = AboutViewController()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setWindowFrame(for viewController: NSViewController) {
        let window = view.window!
        let contentSize = tabViewSizes[viewController.simpleClassName] ?? viewController.view.frame.size
        let newWindowSize = window.frameRect(forContentRect: CGRect(origin: .zero, size: contentSize)).size
        
        var frame = window.frame
        frame.origin.y += frame.height - newWindowSize.height
        frame.size = newWindowSize
        let horizontalDiff = (window.frame.width - frame.size.width) / 2
        frame.origin.x += horizontalDiff
        window.animator().setFrame(frame, display: false)
    }
    
    override func transition(from fromViewController: NSViewController, to toViewController: NSViewController, options: NSViewController.TransitionOptions = [], completionHandler completion: (() -> Void)? = nil) {
        tabViewSizes[fromViewController.simpleClassName] = fromViewController.view.frame.size
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            setWindowFrame(for: toViewController)
            super.transition(from: fromViewController, to: toViewController, options: [.crossfade, .allowUserInteraction], completionHandler: completion)
        }, completionHandler: nil)
    }
    
}

extension TabViewController {
    
    private func setupLayout() {
        let tabItem1 = NSTabViewItem(viewController: vcA)
        tabItem1.label = "General"
        tabItem1.image = NSImage(named: NSImage.preferencesGeneralName)
        self.addTabViewItem(tabItem1)
        
        let tabItem2 = NSTabViewItem(viewController: vcB)
        tabItem2.label = "About"
        tabItem2.image = NSImage(named: NSImage.infoName)
        self.addTabViewItem(tabItem2)
        self.tabStyle = .toolbar
        
        // transitionOptions = [.crossfade]
    }
    
}

extension NSObject {
    /// Returns the class name without module name
    class var simpleClassName: String {
        return String(describing: self)
    }
    
    /// Returns the class name of the instance without module name
    var simpleClassName: String {
        return type(of: self).simpleClassName
    }
    
}
