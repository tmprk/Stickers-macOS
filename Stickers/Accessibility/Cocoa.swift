//
//  Cocoa.swift
//  Stickers
//
//  Created by Timothy Park on 8/19/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

// https://github.com/jtbandes/Mojo/blob/master/Source/Cocoa.swift
extension CGRect {
    /// The bottom-right point when this rectangle is interpreted in screen coordinates.
    var bottomRight: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }
    
    var rightEdge: CGRect {
        return CGRect(x: maxX - 1, y: minY, width: 1, height: height)
    }
}


extension NSObject {
    func addObserver(for name: NSNotification.Name,
                     using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(
            forName: name,
            object: self,
            queue: .main,
            using: block)
    }
}


extension NSScreen {
    /// The screen whose bottom left is at (0, 0).
    static var primary: NSScreen? {
        return NSScreen.screens.first
    }
    
    /// Converts the rectangle from Quartz "display space" to Cocoa "screen space".
    /// <http://stackoverflow.com/a/19887161/23649>
    static func convertFromQuartz(_ rect: CGRect) -> CGRect? {
        return NSScreen.primary.map { screen in
            var result = rect
            result.origin.y = screen.frame.maxY - result.maxY
            return result
        }
    }
}


extension NSStoryboard {
    static let main = NSStoryboard(name: "Main", bundle: .main)
}
