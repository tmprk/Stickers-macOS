//
//  FrontmostApplication.swift
//  Stickers
//
//  Created by Timothy Park on 7/22/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

// https://github.com/IgorMuzyka/Macro/blob/ad23ec70a8c9a231919dc0f99c4a868301e0bd49/Macro/Helpers/FrontmostApplicationWatcher.swift
public class FrontmostApplicationWatcher {
    
    public private(set) var lastKnownFrontmostApplication: NSRunningApplication!
    private let ownBundleIdentifier = Bundle.main.bundleIdentifier!
    static let shared = FrontmostApplicationWatcher()
    
    public init() {
        subscribeForNotifications()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    var frontmostProcessIdentifier: pid_t? {
        get {
            guard let lastApp = lastKnownFrontmostApplication else { return nil }
            return lastApp.processIdentifier
        }
    }
    
    @objc private func handle(_ notification: Notification) {
        guard
            let frontmostApplication = NSWorkspace.shared.frontmostApplication,
            let bundleIdentifier = frontmostApplication.bundleIdentifier,
            bundleIdentifier != ownBundleIdentifier
            else {
                return
        }
        lastKnownFrontmostApplication = frontmostApplication
        // print(lastKnownFrontmostApplication.localizedName as Any)
    }
    
    private func unsubscribeFromNotifications() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    private func subscribeForNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handle), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }
    
}
