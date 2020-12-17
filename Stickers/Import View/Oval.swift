//
//  Oval.swift
//  Stickers
//
//  Created by Timothy Park on 8/3/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa


public class Oval {
    
    var origin: CGPoint
    var size = CGSize.zero
    var path: NSBezierPath!

    init(origin: CGPoint) {
        self.origin = origin
    }

    func draw() {
        path = NSBezierPath()
        path.appendOval(in: boundingBox())
        NSColor.clear.setFill()
        path.fill()
    }

    private func boundingBox() -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
}
