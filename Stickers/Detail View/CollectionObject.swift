//
//  CollectionObject.swift
//  Stickers
//
//  Created by Timothy Park on 7/24/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class CollectionObject: Equatable {
    
    var title: String
    var url: URL
    var creationDate: Date
    var isCollapsed: Bool
    
    var images: [Image] {
        if let images = FileManagerController.shared?.getImages(collection: self) {
            return images.map { Image(url: $0) }
        }
        return []
    }
    
    init(title: String, url: URL, creationDate: Date, isCollapsed: Bool) {
        self.title = title
        self.url = url
        self.creationDate = creationDate
        self.isCollapsed = isCollapsed
    }
    
    static func == (lhs: CollectionObject, rhs: CollectionObject) -> Bool {
        return lhs.title == rhs.title && lhs.url == lhs.url
    }
    
}

class Image: NSObject {
    
    var url: URL
    var img: NSImage {
        return NSImage(byReferencing: url)
    }
    
    init(url: URL) {
        self.url = url
    }
    
}
