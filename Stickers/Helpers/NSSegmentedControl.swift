//
//  NSSegmentedControl.swift
//  Stickers
//
//  Created by Timothy Park on 7/28/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class DispatchingSegmentedControl: NSSegmentedControl {
    
    var segments: [ToolbarSegmentedControlSegment] = []

    func addSegment(toolbarItemIdentifier: NSToolbarItem.Identifier,
                    label: String,
                    action: Selector,
                    menuTitle: String? = nil,
                    menuImage: NSImage? = nil) {
        guard !segments.contains(where: { $0.toolbarItemIdentifier == toolbarItemIdentifier }) else { return }

        let segment = ToolbarSegmentedControlSegment(
            toolbarItemIdentifier: toolbarItemIdentifier,
            label: label,
            action: action,
            menuTitle: menuTitle,
            menuImage: menuImage)
        segments.append(segment)
    }

    func toolbarItems() -> [NSToolbarItem] {
        return segments.map { $0.toolbarItem() }
    }
    
    func wireActionToSelf() {
        self.target = self
        self.action = #selector(segmentSelected(_:))
    }

    @objc func segmentSelected(_ sender: Any) {
        // Dispatch according to `self.selectedSegment`
    }
    
}

struct ToolbarSegmentedControlSegment {

    var toolbarItemIdentifier: NSToolbarItem.Identifier
    var label: String
    var action: Selector
    var menuTitle: String?
    var menuImage: NSImage?

     init(toolbarItemIdentifier: NSToolbarItem.Identifier,
          label: String,
          action: Selector,
          menuTitle: String? = nil,
          menuImage: NSImage? = nil) {
        self.toolbarItemIdentifier = toolbarItemIdentifier
        self.label = label
        self.action = action
        self.menuTitle = menuTitle
        self.menuImage = menuImage
    }
}

extension ToolbarSegmentedControlSegment {
    
    func toolbarItem() -> NSToolbarItem {
        // Do not set the item's action and rely on the ToolbarSegmentedControl instead.
        // This makes it easier to always be running into the same bugs, if any,
        // and not have 2 paths :)
        let item = NSToolbarItem(itemIdentifier: toolbarItemIdentifier)
        item.label = label
        item.title = menuTitle!
        item.image = menuImage
        return item
    }
    
}

extension ToolbarSegmentedControlSegment {
    func dispatchAction() {
        NSApp.sendAction(action, to: nil, from: nil)
    }
}
