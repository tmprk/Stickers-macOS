//
//  PopoverController.swift
//  Stickers
//
//  Created by Timothy Park on 8/19/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class PopoverController: NSViewController {
    
    private let scrollView = NSScrollView()
    private let collectionView = CollectionView()
    
    private let fileManagerController = FileManagerController.shared
    private let watcher = FrontmostApplicationWatcher.shared
    
    private var collection: CollectionObject! {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    lazy var popupButton: NSPopUpButton = {
        let popupButton = NSPopUpButton()
        popupButton.translatesAutoresizingMaskIntoConstraints = false
        popupButton.bezelStyle = .texturedRounded
        popupButton.target = self
        popupButton.action = #selector(onSelected)
        popupButton.pullsDown = false
        return popupButton
    }()
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
        view.wantsLayer = true
        buildPopupButton()
        loadCollection()
        layoutViews()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        collectionView.deselectAll(self)
    }
    
    func loadCollection() {
        if GlobalSettings.selectedCollection != "" {
            collection = fileManagerController?.getLastCollection(GlobalSettings.selectedCollection)
            print("selecting", GlobalSettings.selectedCollection)
            popupButton.selectItem(withTitle: GlobalSettings.selectedCollection)
        } else {
            if let itemToSelect = fileManagerController?.getLastCollection() {
                print("select:", itemToSelect.title)
                collection = itemToSelect
                popupButton.selectItem(withTitle: itemToSelect.title)
            }
        }
    }
    
    func buildPopupButton() {
        if let collectionsList = FileManagerController.shared?.getCollectionsList() {
            popupButton.addItems(withTitles: collectionsList)
        }
    }
    
    func layoutViews() {
        let flowLayout = WaterfallFlowLayout()
        flowLayout.columnCount = 3
        flowLayout.minimumColumnSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = flowLayout
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.isSelectable = true
        collectionView.register(CollectionViewItem.self, forItemWithIdentifier: CollectionViewItem.identifier)
        
        scrollView.wantsLayer = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = collectionView
        scrollView.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        
        view.addSubview(popupButton)
        view.addSubview(scrollView)
        
        let popupButtonConstraints = [
            popupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.labelInsets.left),
            popupButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Styles.labelInsets.top),
            popupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Styles.labelInsets.right),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            scrollView.topAnchor.constraint(equalTo: popupButton.bottomAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(popupButtonConstraints)
    }
    
    @objc func onSelected(_ sender: NSPopUpButton) {
        if let menuTitle = sender.selectedItem?.title {
            GlobalSettings.selectedCollection = menuTitle
            loadCollection()
        }
    }
    
}

// MARK: - NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout
extension PopoverController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.images.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: CollectionViewItem.identifier, for: indexPath) as! CollectionViewItem
        item.image = collection.images[indexPath.item]
        item.isSelected = false
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        if collectionView.numberOfItems(inSection: section) > 0 {
            let inset = view.frame.size.width / 40
            return NSEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        } else {
            return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        guard let item = collectionView.item(at: indexPath) as? CollectionViewItem else { return }
        item.isSelected = true
        
        let sticker = collection.images[indexPath.item]
        writeImageToPasteboard(img: sticker.img)
        
        if let pid = watcher.frontmostProcessIdentifier {
            switchApp(process: pid) { [weak self] (success) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    // NSApp.deactivate()
                    // strongSelf.watcher.simulateKey(0x09)
                    FakeKey.simulateKey(0x09)
                    strongSelf.view.window?.close()
                    // NotificationCenter.default.post(name: NSPopover.willCloseNotification, object: nil, userInfo: ["status":true])
                }
            }
        }
    }
    
}

// MARK: - WaterfallFlowLayoutDelegate
extension PopoverController: WaterfallFlowLayoutDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let model = collection.images[indexPath.item]
        let imageSize = model.img.size
        return CGSize(width: imageSize.width, height: imageSize.height)
    }
    
}

extension PopoverController {
    
    func switchApp(process: Int32, completion: (Bool) -> ()) {
        let app = NSRunningApplication(processIdentifier: process)
        app?.activate(options: .activateIgnoringOtherApps)
        completion(true)
    }
    
    func writeImageToPasteboard(img: NSImage) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([img])
    }

}
