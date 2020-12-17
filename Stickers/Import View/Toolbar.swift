//
//  Toolbar.swift
//  Stickers
//
//  Created by Timothy Park on 4/19/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

protocol CanvasDelegate: class {
    func activateMode(index: Int)
    func resetMask()
    func setBorderColor(color: NSColor)
    func setBorderWidth(width: CGFloat)
    func showSavePanel()
}

protocol ManagerDelegate: class {
    func deleteStickers()
}

struct ToolbarIdentifiers {
    static let managerToolbar = NSToolbar.Identifier(stringLiteral: "ManagerToolbar")
    static let preferencesToolbar = NSToolbar.Identifier(stringLiteral: "PreferencesToolbar")
    static let navGroupItem = NSToolbarItem.Identifier(rawValue: "NavGroupToolbarItem")
    static let resetItem = NSToolbarItem.Identifier("ResetItem")
    static let colorWellItem = NSToolbarItem.Identifier("ColorWellItem")
    static let sliderItem = NSToolbarItem.Identifier("SliderItem")
    static let saveItem = NSToolbarItem.Identifier("SaveItem")
    static let trashItem = NSToolbarItem.Identifier("TrashItem")
}

class Toolbar: NSToolbar, NSToolbarDelegate {
    
    weak var mainDelegate: CanvasDelegate?
    public var managerDelegate: ManagerDelegate?
    var toolbarItemList = [ToolbarItem]()
    var availableItemsIdentifiers: [NSToolbarItem.Identifier] { return toolbarItemList.map({ $0.identifier }) }
    
    override init(identifier: NSToolbar.Identifier) {
        super.init(identifier: identifier)
        if identifier == ToolbarIdentifiers.preferencesToolbar {
            toolbarItemList.append(InitializeToolbar.resetItem(#selector(resetItemAction), target: self))
            toolbarItemList.append(ToolbarItem(.flexibleSpace))
            toolbarItemList.append(InitializeToolbar.navGroupItem(#selector(segmentedControlSentAction), target: self))
            toolbarItemList.append(ToolbarItem(.flexibleSpace))
            toolbarItemList.append(InitializeToolbar.colorWellItem(#selector(colorWellItemAction), target: self))
            toolbarItemList.append(ToolbarItem(.flexibleSpace))
            toolbarItemList.append(InitializeToolbar.sliderItem(#selector(sliderChanged), target: self))
            toolbarItemList.append(ToolbarItem(.flexibleSpace))
            toolbarItemList.append(InitializeToolbar.saveItem(#selector(saveSticker), target: self))
        }
        if identifier == ToolbarIdentifiers.managerToolbar {
            toolbarItemList.append(ToolbarItem(.flexibleSpace))
            toolbarItemList.append(InitializeToolbar.trashItem(#selector(trashStickers), target: self))
        }
        displayMode = (identifier == ToolbarIdentifiers.preferencesToolbar) ? .iconAndLabel : .iconOnly
        showsBaselineSeparator = true
        allowsUserCustomization = false
        delegate = self
    }
    
    //MARK: - NSToolbarDelegate
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        guard let item = toolbarItemList.firstIndex(where: { $0.identifier == itemIdentifier }) else { return nil }
        switch toolbarItemList[item].identifier {
        case ToolbarIdentifiers.navGroupItem:
            return toolbarItemList[item].segmentedControl()
        case ToolbarIdentifiers.resetItem:
            return toolbarItemList[item].imageButton()
        case ToolbarIdentifiers.colorWellItem:
            return toolbarItemList[item].colorWellItem()
        case ToolbarIdentifiers.sliderItem:
            return toolbarItemList[item].sliderItem()
        case ToolbarIdentifiers.saveItem:
            return toolbarItemList[item].imageButton()
        case ToolbarIdentifiers.trashItem:
            return toolbarItemList[item].imageButton()
        default:
            return nil
        }
    }
    
    @objc func segmentedControlSentAction(_ sender: Any) {
        guard let toolbarItem = sender as? NSToolbarItem else { return }
        DispatchQueue.main.async { [weak self] in
            GlobalSettings.drawMode = toolbarItem.tag
            self?.mainDelegate?.activateMode(index: toolbarItem.tag)
        }
        selectedItemIdentifier = nil
    }
    
    @objc func resetItemAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.mainDelegate?.resetMask()
        }
    }
    
    @objc func colorWellItemAction(_ sender: NSColorWell) {
        DispatchQueue.main.async { [weak self] in
            self?.mainDelegate?.setBorderColor(color: sender.color)
        }
        UserDefaults.standard.set(sender.color, forKey: "borderColor")
    }
    
    @objc func sliderChanged(_ sender: NSSlider?) {
        if let sl = sender {
            let widthBefore = CGFloat(sl.floatValue)
            DispatchQueue.main.async { [weak self] in
                self?.mainDelegate?.setBorderWidth(width: widthBefore * 2)
            }
            GlobalSettings.borderWidth = widthBefore
        }
    }
    
    @objc func saveSticker() {
        DispatchQueue.main.async { [weak self] in
            self?.mainDelegate?.showSavePanel()
        }
    }
    
    @objc func trashStickers() {
        DispatchQueue.main.async { [weak self] in
            self?.managerDelegate?.deleteStickers()
        }
    }
    
    @objc func toolbarItemSentAction(_ sender: Any) {
        selectedItemIdentifier = nil
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.availableItemsIdentifiers
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarWillAddItem(_ notification: Notification) {
        // print("toolbarWillAddItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }

    func toolbarDidRemoveItem(_ notification: Notification) {
        // print("toolbarDidRemoveItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }
    
}

struct ToolbarItem {
    
    let identifier: NSToolbarItem.Identifier
    let label: String
    let paletteLabel: String?
    let image: NSImage?
    let width: CGFloat
    let height: CGFloat
    let action: Selector?
    weak var target: AnyObject?
    var menuItem: NSMenuItem? = nil // Needs to be plugged in after App has launched.
    let group: [ToolbarItem]?
    let tooltip: String?
    
    init(_ identifier: NSToolbarItem.Identifier, label: String = "", image: NSImage? = nil, width: CGFloat = 38.0, height: CGFloat = 28.0, action: Selector? = nil, target: AnyObject? = nil, group: [ToolbarItem]? = nil, paletteLabel: String? = nil, tooltip: String? = nil) {
        self.identifier = identifier
        self.label = label
        self.paletteLabel = paletteLabel
        self.width = width
        self.height = height
        self.image = image
        self.action = action
        self.target = target
        self.group = group
        self.tooltip = tooltip
    }
    
}

struct InitializeToolbar {
    
    static func navGroupItem(_ action: Selector, target: AnyObject) -> ToolbarItem {
        var group = [ToolbarItem]()
        group.append(ToolbarItem(NSToolbarItem.Identifier("Freehand"), label: "Freehand", image: NSImage(named: "cloud"), width: 53, height: 20, action: nil, target: target, paletteLabel: ""))
        group.append(ToolbarItem(NSToolbarItem.Identifier("Ellipse"), label: "Ellipse", image: NSImage(named: "ellipse"), width: 53, height: 20, action: nil, target: target, paletteLabel: ""))
        group.append(ToolbarItem(NSToolbarItem.Identifier("Square"), label: "Square", image: NSImage(named: "square"), width: 53, height: 20, action: nil, target: target, paletteLabel: ""))
        let item = ToolbarItem(ToolbarIdentifiers.navGroupItem, width: 200, height: 28, action: action, target: target, group: group, paletteLabel: "Navigation")
        return item
    }
    
    static func resetItem(_ action: Selector, target: AnyObject) -> ToolbarItem {
        let item = ToolbarItem(ToolbarIdentifiers.resetItem, label: "Clear", image: NSImage(named: "restore"), action: action, target: target, tooltip: "Reset: clear existing shapes.")
        return item
    }
    
    static func colorWellItem(_ action: Selector, target: AnyObject) -> ToolbarItem {
        let item = ToolbarItem(ToolbarIdentifiers.colorWellItem, label: "Color", action: action, target: target, tooltip: "Select color for sticker border.")
        return item
    }
    
    static func sliderItem(_ action: Selector, target: AnyObject) -> ToolbarItem {
        let item = ToolbarItem(ToolbarIdentifiers.sliderItem, label: "Width", width: 60, action: action, target: target, tooltip: "Select the size of the sticker border.")
        return item
    }
    
    static func saveItem(_ action: Selector, target: AnyObject) -> ToolbarItem {
        let item = ToolbarItem(ToolbarIdentifiers.saveItem, label: "Save", image: NSImage(named: NSImage.touchBarFolderMoveToTemplateName), action: action, target: target, tooltip: "Save sticker to collection.")
        return item
    }
    
    static func trashItem(_ action: Selector, target: AnyObject) -> ToolbarItem {
        let item = ToolbarItem(ToolbarIdentifiers.trashItem, label: "Trash", image: NSImage(named: NSImage.trashFullName), action: action, target: target, tooltip: "Delete sticker(s).")
        return item
    }
    
}

extension ToolbarItem {
    
    func imageButton() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: identifier)
        item.label = label
        item.paletteLabel = label
        item.menuFormRepresentation = menuItem // Need this for text-only to work
        item.toolTip = tooltip
        let button = NSButton(image: image!, target: target, action: action)
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        button.title = ""
        button.imageScaling = .scaleProportionallyDown
        button.bezelStyle = .texturedRounded
        button.focusRingType = .none
        item.view = button
        return item
    }
    
    func segmentedControl() -> NSToolbarItemGroup {
        let itemGroup = NSToolbarItemGroup(itemIdentifier: identifier)
        let control = NSSegmentedControl(frame: NSRect(x: 0, y: 0, width: width, height: height))
        control.segmentStyle = .texturedSquare
        control.trackingMode = .selectOne
        control.segmentCount = group!.count
        control.focusRingType = .none
        
        var items = [NSToolbarItem]()
        for (index, segment) in group!.enumerated() {
            let item = NSToolbarItem(itemIdentifier: segment.identifier)
            item.title = segment.label
            item.label = segment.label
            item.tag = index
            item.action = action
            item.target = target
            control.target = segment.target
            control.setImage(segment.image, forSegment: index)
            control.setImageScaling(.scaleProportionallyDown, forSegment: index)
            control.setWidth(segment.width, forSegment: index)
            control.setTag(index, forSegment: index)
            if let cell = control.cell as? NSSegmentedCell {
                cell.setTag(index, forSegment: index)
            }
            item.tag = index // added for iconAndLabel mode
            items.append(item)
        }
        control.action = action
        itemGroup.paletteLabel = label
        itemGroup.subitems = items
        itemGroup.view = control
        control.selectedSegment = GlobalSettings.drawMode
        return itemGroup
    }
    
    func colorWellItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: identifier)
        item.label = label
        item.paletteLabel = label
        item.toolTip = tooltip
        let colorWell = NSColorWell()
        colorWell.target = target
        colorWell.action = action
        colorWell.widthAnchor.constraint(equalToConstant: width).isActive = true
        colorWell.heightAnchor.constraint(equalToConstant: height).isActive = true
        colorWell.isBordered = true
        colorWell.focusRingType = .none
        colorWell.color = UserDefaults.standard.color(forKey: "borderColor") ?? NSColor.white
        item.view = colorWell
        return item
    }
    
    func sliderItem() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: identifier)
        item.label = label
        item.paletteLabel = label
        item.toolTip = tooltip
        
        let slider = ScrollableSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true
        slider.minValue = 0
        slider.maxValue = 20
        slider.target = target
        slider.action = action
        slider.widthAnchor.constraint(equalToConstant: width).isActive = true
        slider.heightAnchor.constraint(equalToConstant: height).isActive = true
        slider.floatValue = Float(GlobalSettings.borderWidth)
        slider.focusRingType = .none
        item.view = slider
        return item
    }
    
}
