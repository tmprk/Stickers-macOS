//
//  DetailController.swift
//  Stickers
//
//  Created by Timothy Park on 4/18/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class DetailController: NSViewController {
    
    private let scrollView = NSScrollView()
    private let collectionView = CollectionView()
    private var keyDownEventMonitor: Any! = nil
    
    private var collections: [CollectionObject] = []
    private let fileManagerController = FileManagerController.shared
    private let watcher = FrontmostApplicationWatcher.shared
    
    public var selectedCollection: CollectionObject? {
        didSet {
            if let selectedCollection = selectedCollection {
                let ctx = NSAnimationContext.current
                ctx.allowsImplicitAnimation = true
                guard let sectionIndex = collections.firstIndex(of: selectedCollection) else { return }
                scrollToHeader(at: sectionIndex)
            }
        }
    }
    
    override func loadView() {
        let frameView = NSView(frame: CGRect(x: 0, y: 0, width: 400, height: 500))
        view = frameView
        loadCollections()
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadStickers), name: .collectionsChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadStickers()
    }
    
    func loadCollections() {
        if let collections = fileManagerController?.getCollections() {
            self.collections = collections
        }
    }
    
    func setupCollectionView() {
        let flowLayout = WaterfallFlowLayout()
        flowLayout.columnCount = 5
        flowLayout.minimumColumnSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.headerHeight = 30
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.menuSource = self
        collectionView.collectionViewLayout = flowLayout
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.isSelectable = true
        collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, withIdentifier: HeaderCell.identifier)
        collectionView.register(CollectionViewItem.self, forItemWithIdentifier: CollectionViewItem.identifier)
        collectionView.deleteAction = { [unowned self] in
            self.deleteSelectedStickers()
        }
        
        scrollView.documentView = collectionView
        scrollView.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        view = scrollView
    }
    
    @objc func reloadStickers() {
        DispatchQueue.main.async {
            self.loadCollections()
            self.collectionView.reloadData()
        }
    }
    
    @objc func deleteSelectedStickers() {
        let paths = self.collectionView.selectionIndexPaths
        let sections = paths.map({ $0.section })
        for path in paths {
            let collectionObj = self.collections[path.section]
            let image = collectionObj.images[path.item]
            self.fileManagerController?.deleteSticker(image.url)
        }
        self.loadCollections()
        self.collectionView.reloadSections(IndexSet(sections))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .collectionsChanged, object: nil)
    }
    
}


// MARK: - NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout
extension DetailController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return collections.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collections[section].isCollapsed {
            return 0
        } else {
            return collections[section].images.count
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionHeader {
            let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: HeaderCell.identifier, for: indexPath) as! HeaderCell
            // let menu = app.menus[indexPath.section]
            // view.frame = NSRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 30)
            let collection = collections[indexPath.section]
            view.titleLabel.stringValue = collection.title
            view.countLabel.stringValue = "\(collection.images.count) Stickers"
            view.section = indexPath.section
            view.delegate = self
            return view
        } else {
            return NSView()
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: CollectionViewItem.identifier, for: indexPath) as! CollectionViewItem
        item.image = collections[indexPath.section].images[indexPath.item]
        item.isSelected = false
        return item
    }
    
}

// MARK: - WaterfallFlowLayoutDelegate
extension DetailController: WaterfallFlowLayoutDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let model = collections[indexPath.section].images[indexPath.item]
        let imageSize = model.img.size
        return CGSize(width: imageSize.width, height: imageSize.height)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, insetForSection section: Int) -> NSEdgeInsets {
        if collectionView.numberOfItems(inSection: section) > 0 {
            return NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        } else {
            return NSEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
    }
    
}

extension DetailController {
    
    func switchApp(process: Int32, completion: (Bool) -> ()) {
        let app = NSRunningApplication(processIdentifier: process)
        app?.activate(options: .activateIgnoringOtherApps)
        completion(true)
    }
    
    // 51 or (0x33) for backspace
    
    func writeImageToPasteboard(img: NSImage) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([img])
    }
    
    func scrollToHeader(at section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        if let attributes = collectionView.layoutAttributesForItem(at: indexPath), let height = collectionView.layoutAttributesForSupplementaryElement(ofKind: NSCollectionView.elementKindSectionHeader, at: indexPath)?.frame.height {
            let inset = view.frame.size.width / 40
            let topOfHeader = NSPoint(x: 0, y: attributes.frame.origin.y - inset - height)
            collectionView.scroll(topOfHeader)
        }
    }
    
}

// MARK: - CollectionViewMenuSource
extension DetailController: CollectionViewMenuSource {
    
    func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu()
        let point = collectionView.convert(event.locationInWindow, from: nil)
        
        // There's a possibility that user right click on empty space between cell items
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return .none
        }
        
        let showChapters = NSMenuItem(title: "Select Sticker", action: #selector(DetailController.selectSticker(item:)), keyEquivalent: "")
        showChapters.representedObject = indexPath
        
        let delete = NSMenuItem(title: "Delete Sticker", action: #selector(DetailController.deleteSticker(item:)), keyEquivalent: "")
        delete.representedObject = indexPath
        menu.addItem(showChapters)
        menu.addItem(delete)
        return menu
    }
    
    @objc func selectSticker(item: NSMenuItem) {
        let indexPath = item.representedObject as! IndexPath
        collectionView.selectItems(at: Set([indexPath]), scrollPosition: .top)
        // collectionView(collectionView, didSelectItemsAt: Set([indexPath]))
    }
    
    @objc func deleteSticker(item: NSMenuItem) {
        let indexPath = item.representedObject as! IndexPath
        let collectionObject = self.collections[indexPath.section]
        let image = collectionObject.images[indexPath.item]
        self.fileManagerController?.deleteSticker(image.url)
        collectionView.animator().performBatchUpdates({
            let indexSet = IndexSet(integer: indexPath.section)
            collectionView.collectionViewLayout!.invalidateLayout()
            loadCollections()
            collectionView.reloadSections(indexSet)
        })
    }
    
}

// MARK: - ExpandedCellDelegate
extension DetailController: ExpandedCellDelegate {
    
    func deleteButtonSelected(section: Int) {
        print("delete button")
    }
    
    func topButtonTouched(section: Int) {
        collections[section].isCollapsed = !collections[section].isCollapsed
        collectionView.animator().performBatchUpdates({
            let indexSet = IndexSet(integer: section)
            collectionView.collectionViewLayout!.invalidateLayout()
            collectionView.reloadSections(indexSet)
        })
    }
    
}
