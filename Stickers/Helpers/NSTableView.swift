//
//  NSTableView.swift
//  Stickers
//
//  Created by Timothy Park on 7/26/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

extension NSTableView {

    func reloadDataKeepingSelection() {
        let selectedRowIndexes = self.selectedRowIndexes
        reloadData(forRowIndexes: IndexSet(0...numberOfRows), columnIndexes: IndexSet(integer: 0))
        selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }
    
}
