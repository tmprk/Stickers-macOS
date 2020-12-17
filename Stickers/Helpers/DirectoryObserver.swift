//
//  DirectoryObserver.swift
//  Stickers
//
//  Created by Timothy Park on 7/27/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class DirectoryObserver {
    
    private let fileDescriptor: CInt
    private let source: DispatchSourceProtocol
    
    deinit {
        self.source.cancel()
        close(fileDescriptor)
    }
    
    init(URL: URL, block: @escaping ()->Void) {
        self.fileDescriptor = open(URL.path, O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor, eventMask: .all, queue: DispatchQueue.global())
        self.source.setEventHandler {
            block()
        }
        self.source.resume()
    }
    
}

import Foundation

@objc public class DirectoryWatcher: NSObject {
    
    override public init() {
        super.init()
    }

    deinit {
        stop()
    }

    public typealias Callback = (_ directoryWatcher: DirectoryWatcher) -> Void

    @objc public convenience init(withPath path: String, callback: @escaping Callback) {
        self.init()
        if !watch(path: path, callback: callback) {
            assert(false)
        }
    }

    private var dirFD: Int32 = -1 {
        didSet {
            if oldValue != -1 {
                close(oldValue)
            }
        }
    }
    private var dispatchSource: DispatchSourceFileSystemObject?

    @objc public func watch(path: String, callback: @escaping Callback) -> Bool {
        // Open the directory
        dirFD = open(path, O_EVTONLY)
        if dirFD < 0 {
            return false
        }

        // Create and configure a DispatchSource to monitor it
        let dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: dirFD, eventMask: .write, queue: DispatchQueue.main)
        dispatchSource.setEventHandler {[unowned self] in
            callback(self)
        }
        dispatchSource.setCancelHandler {[unowned self] in
            self.dirFD = -1
        }
        self.dispatchSource = dispatchSource

        // Start monitoring
        dispatchSource.resume()

        // Success
        return true
    }

    @objc public func stop() {
        // Leave if not monitoring
        guard let dispatchSource = dispatchSource else {
            return
        }

        // Don't listen to more events
        dispatchSource.setEventHandler(handler: nil)

        // Cancel the source (this will also close the directory)
        dispatchSource.cancel()
        self.dispatchSource = nil
    }
    
}
