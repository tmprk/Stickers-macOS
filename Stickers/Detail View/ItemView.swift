//
//  ItemView.swift
//  Stickers
//
//  Created by Timothy Park on 4/21/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class ItemView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        // fillGradientLayer()
    }
    
    func fillGradientLayer() {
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = NSColor.systemGray.cgColor
        yourViewBorder.lineWidth = 3
        yourViewBorder.masksToBounds = true
        yourViewBorder.lineDashPattern = [10, 7]
        yourViewBorder.frame = bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6).cgPath
        self.layer?.addSublayer(yourViewBorder)
    }
    
}
