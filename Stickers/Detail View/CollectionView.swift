//
//  CollectionView.swift
//  Stickers
//
//  Created by Timothy Park on 7/20/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

// https://github.com/sendyhalim/Yomu/blob/7bb9a4db4d397a280d719b8b55837b7778d53a28/Yomu/Common/Views/MenuableCollectionView.swift
protocol CollectionViewMenuSource: AnyObject {
    func menu(for event: NSEvent) -> NSMenu?
}

extension CollectionViewMenuSource {
    func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
}

class CollectionView: NSCollectionView {
    
    // https://github.com/PierreLorenzi/HyperCardPreview/blob/8402f9de936eacfbb2c98bbb074506c70b465f34/HyperCardPreview/CollectionView.swift
    var deleteAction: (() -> Void)? = nil
    
    weak var menuSource: CollectionViewMenuSource?
    
    // override var canBecomeKeyView: Bool {
    //     return true
    // }
    
    // override var acceptsFirstResponder: Bool {
    //     return true
    // }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuSource?.menu(for: event)
    }
    
    override func keyDown(with event: NSEvent) {
        if let ascii = event.characters?.first?.unicodeScalars.first?.value, ascii == NSBackspaceCharacter || ascii == NSDeleteCharacter {
            if let action = deleteAction {
                action()
            }
        } else {
            super.keyDown(with: event)
        }
    }
    
}
