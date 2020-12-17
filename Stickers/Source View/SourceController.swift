//
//  ViewController.swift
//  Stickers
//
//  Created by Timothy Park on 4/17/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class TableView: NSTableView {
    
    // override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
    //     return true
    // }
    
    override func setFrameSize(_ newSize: NSSize) {
        let padded = NSSize(width: newSize.width, height: newSize.height+30)
        super.setFrameSize(padded)
    }
    
    override func drawGrid(inClipRect clipRect: NSRect) { }
    
}

class SourceController: NSViewController {
    
    private let scrollView = NSScrollView()
    private let tableView = TableView()
    
    private let addButton: NSButton = {
        let addButton = NSButton()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.image = NSImage(named: NSImage.addTemplateName)
        addButton.bezelStyle = .roundRect
        addButton.isBordered = false
        addButton.action = #selector(addAction)
        return addButton
    }()
    
    private var collections: [CollectionObject]?
    private var fileManagerController = FileManagerController.shared
    
    private var directoryObserver: DirectoryObserver?
    // private var directoryWatcher: DirectoryWatcher?
    private let defaults = UserDefaults.standard
    
    override func loadView() {
        let frameView = NSView()
        view = frameView
        loadCollections()
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: .collectionsChanged, object: nil)
        directoryObserver = DirectoryObserver(URL: fileManagerController!.collectionsURL, block: {
            NotificationCenter.default.post(name: .collectionsChanged, object: nil)
        })
    }
    
    func loadCollections() {
        let collections = fileManagerController?.getCollections()
        self.collections = collections
    }
    
    @objc func reloadTable() {
        DispatchQueue.main.async {
            self.loadCollections()
            self.tableView.reloadData()
        }
    }
    
    func setupTableView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.autoresizingMask = [.height, .width]
        tableView.sizeLastColumnToFit()
        tableView.allowsColumnResizing = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.selectionHighlightStyle = .regular
        tableView.headerView = nil
        tableView.allowsMultipleSelection = false
        tableView.usesAutomaticRowHeights = true
        tableView.selectionHighlightStyle = .regular
        tableView.gridStyleMask = .solidHorizontalGridLineMask
        
        let newColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "title"))
        tableView.addTableColumn(newColumn)
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Edit", action: #selector(tableViewEditItemClicked(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(tableViewDeleteItemClicked(_:)), keyEquivalent: ""))
        tableView.menu = menu
        
        view.addSubview(addButton, positioned: .above, relativeTo: scrollView)
        let segmentedControlConstraints = [
            // segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styles.insets.left),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Styles.labelInsets.bottom),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Styles.labelInsets.right)
        ]
        NSLayoutConstraint.activate(segmentedControlConstraints)
        
        scrollView.backgroundColor = NSColor.clear
        scrollView.drawsBackground = false
        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false
    }
    
    @objc func addAction(_ sender: AnyObject) {
        fileManagerController?.createNewCollection({ (success) in
            if success {
                reloadTable()
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let view = self.tableView.view(atColumn: 0, row: self.collections!.count - 1, makeIfNecessary: false) as! SourceViewCell
            self.tableView.window?.makeFirstResponder(view.textfield)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .collectionsChanged, object: nil)
    }
    
}

// MARK: - NSTableViewDelegate + NSTableViewDataSource
extension SourceController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let collections = collections else { return 0 }
        return collections.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let collections = collections else { return nil }
        let cell = SourceViewCell()
        cell.set(title: collections[row].title, onUpdateSession: onUpdateSession(at: row))
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        var actions: [NSTableViewRowAction] = []
        if edge == .trailing {
            let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete", handler: { (rowAction, row) in
                self.confirmRemoval { (result) in
                    if result {
                        self.collections!.remove(at: row)
                        tableView.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
                    }
                }
            })
            deleteAction.backgroundColor = NSColor.red
            actions.append(deleteAction)
        }
        return actions
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let collections = collections else { return }
        let selectedRow = tableView.selectedRow
        if selectedRow != -1 {
            let collection = collections[selectedRow]
            GlobalSettings.selectedCollection = collection.title
            
            let parentController = (parent as! SplitViewController)
            let detailedController = (parentController.children[1] as! DetailController)
            detailedController.selectedCollection = collection
        }
    }
    
}


extension SourceController {
    
    @objc func lol() {
        // print(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first)
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let appSupport = paths.first
        if let files = try? FileManager.default.contentsOfDirectory(atPath: appSupport!) {
            for file in files {
                print(file)
            }
        }
        alertDialog(message: "Create a New Collection") { [unowned self] (answer, title) in
            self.createNewCollection(name: title)
        }
    }
    
    func createNewCollection(name: String) {
        let fileManager = FileManager.default
        do {
            let documentDirectoryPath = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create:false)
            let collectionsDirectoryPath = documentDirectoryPath.appendingPathComponent("Collections", isDirectory: true)
            let collectionURL = collectionsDirectoryPath.appendingPathComponent(name)
            if !fileManager.fileExists(atPath: collectionURL.path) {
                do {
                    try fileManager.createDirectory(atPath: collectionURL.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating images folder in documents dir: \(error)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func alertDialog(message: String, completion: @escaping (Bool, String)->() ) {
        let alert: NSAlert = NSAlert()
        alert.alertStyle = NSAlert.Style.informational
        alert.messageText = message
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 23))
        alert.accessoryView = txt
        
        alert.addButton(withTitle: "Create")
        alert.addButton(withTitle: "Cancel")
        
        alert.window.initialFirstResponder = txt
        alert.beginSheetModal(for: view.window!, completionHandler: { result in
            completion(result == NSApplication.ModalResponse.alertFirstButtonReturn, txt.stringValue)
        })
    }
    
    func confirmRemoval(completion: @escaping (Bool)->() ) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Are you sure you want to delete this sticker collection?"
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: view.window!, completionHandler: { result in
            completion(result == NSApplication.ModalResponse.alertFirstButtonReturn)
        })
    }
    
    private func onUpdateSession(at row: Int) -> ((String)->()) {
        return  { newSessionName in
            print("row", index, "new name:", newSessionName)
            if let item = self.collections?[row] {
                self.fileManagerController?.renameItem(item.title, newName: newSessionName)
                self.loadCollections()
            }
            self.tableView.reloadData()
        }
    }
    
    @objc private func tableViewEditItemClicked(_ sender: AnyObject) {
        guard tableView.clickedRow >= 0 else { return }
        let row = tableView.clickedRow
        let view = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! SourceViewCell
        tableView.window?.makeFirstResponder(view.textfield)
    }
    
    @objc private func tableViewDeleteItemClicked(_ sender: AnyObject) {
        guard tableView.clickedRow >= 0 else { return }
        let row = tableView.clickedRow
        if let item = self.collections?[row] {
            fileManagerController?.deleteCollection(item.title, completion: { (success) in
                if success {
                    loadCollections()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
}

