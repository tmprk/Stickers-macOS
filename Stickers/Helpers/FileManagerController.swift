//
//  FileManagerController.swift
//  Stickers
//
//  Created by Timothy Park on 7/24/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class FileManagerController {
    
    var collectionsURL: URL
    let fileManager = FileManager.default
    let bundleID = Bundle.main.bundleIdentifier!
    static let shared: FileManagerController? = try? FileManagerController() // singleton
    
    init() throws {
        do {
            collectionsURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(bundleID).appendingPathComponent("Collections")
        } catch let error as NSError {
            throw error
        }
    }
    
    func createCollectionsDirectory() {
        let fileManager = FileManager.default
        let bundleID = Bundle.main.bundleIdentifier!
        do {
            let applicationSupport = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let collectionsDirectory = applicationSupport.appendingPathComponent(bundleID, isDirectory: true).appendingPathComponent("Collections")
            if !fileManager.fileExists(atPath: collectionsDirectory.path) {
                try fileManager.createDirectory(at: collectionsDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Cannot create directory in Application Support")
        }
    }
    
    func getLastCollection(_ title: String? = nil) -> CollectionObject {
        var singleCollection: CollectionObject!
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: collectionsURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            if !fileURLs.isEmpty {
                let sortedURLs = fileURLs.sorted(by: { $0.creationDate! > $1.creationDate! })
                if let title = title, let object = sortedURLs.first(where: { $0.localizedName == title }) {
                    singleCollection = CollectionObject(title: title, url: object, creationDate: object.creationDate!, isCollapsed: false)
                } else {
                    singleCollection = CollectionObject(title: sortedURLs[0].localizedName, url: sortedURLs[0], creationDate: sortedURLs[0].creationDate!, isCollapsed: false)
                }
            }
        } catch {
            print("Cannot get Collections folder in Application Support")
        }
        return singleCollection
    }
    
    func getCollections() -> [CollectionObject] {
        var isDir: ObjCBool = true
        if !fileManager.fileExists(atPath: collectionsURL.path, isDirectory:&isDir) {
            print("no collections directory exists, so creating one")
            createCollectionsDirectory()
        }
        var collectionObjectArray: [CollectionObject] = []
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: collectionsURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            if !fileURLs.isEmpty {
                collectionObjectArray = fileURLs.filter{
                    $0.isFolder
                }.map {
                    CollectionObject(title: $0.localizedName, url: $0, creationDate: $0.creationDate!, isCollapsed: false)
                }.sorted(by: {
                    $0.creationDate < $1.creationDate
                })
            }
        } catch {
            print("Cannot get Collections folder in Application Support")
        }
        return collectionObjectArray
    }
    
    func getCollectionsList() -> [String]? {
        let collectionsList = getCollections().sorted(by: { $0.url.modificationDate! > $1.url.modificationDate! }).map({ $0.url.lastPathComponent })
        return collectionsList
    }
    
    func getImages(collection: CollectionObject) -> [URL]! {
        var contentArray: [URL] = []
        // We are populating our collection view from a file system directory URL.
        let urlToDirectory = collection.url
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: urlToDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            for element in fileURLs where element.isImage {
                // Only allow visible objects.
                let isHidden = element.isHidden
                if !isHidden {
                    // File system object is visible so add to our content array.
                    contentArray.append(element)
                }
            }
        } catch _ {}
        return contentArray
    }
    
    func deleteCollection(_ title: String, completion: (Bool) -> Void) {
        let pathToDir = collectionsURL.appendingPathComponent(title, isDirectory: true)
        do {
            try fileManager.removeItem(at: pathToDir)
            completion(true)
        } catch let error as NSError {
            print("An error took place: \(error)")
            completion(false)
        }
    }
    
    func deleteSticker(_ stickerURL: URL) {
        do {
            try fileManager.removeItem(at: stickerURL)
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    func renameItem(_ title: String, newName: String) {
        let oldPath = collectionsURL.appendingPathComponent(title, isDirectory: true)
        let newPath = collectionsURL.appendingPathComponent(newName, isDirectory: true)
        do {
            try fileManager.moveItem(at: oldPath, to: newPath)
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    func createNewCollection(_ completion: (Bool) -> Void) {
        do {
            try fileManager.createDirectory(at: collectionsURL.appendingPathComponent("untitled folder"), withIntermediateDirectories: false, attributes: nil)
            completion(true)
        } catch let error as NSError {
            print("An error took place: \(error)")
            completion(false)
        }
    }
    
}
