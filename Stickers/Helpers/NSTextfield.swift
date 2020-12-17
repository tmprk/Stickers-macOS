//
//  NSTextfield.swift
//  Stickers
//
//  Created by Timothy Park on 7/25/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class Textfield: NSTextField {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        appearance = NSAppearance.init(named: .darkAqua)
        textColor = NSColor.headerTextColor
        font = NSFont.systemFont(ofSize: 14, weight: .medium)
        alignment = .left
        lineBreakMode = .byTruncatingTail
        
        drawsBackground = false
        isBezeled = false
        isBordered = false
        isEditable = false
        isSelectable = false
        focusRingType = .none
        
        // textColor = .labelColor
        // wantsLayer = true
        // backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// https://github.com/lwouis/alt-tab-macos/blob/60bf384e43745d9a7a9df8cd9d90befb068694f9/src/ui/generic-components/text/TextField.swift
class MarkdownTextfield: NSTextField {
    // NSTextField has 2px insets left and right by default; we remove those
    let insets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    override var alignmentRectInsets: NSEdgeInsets { insets }

    convenience init(_ labelWithString: String) {
        self.init(labelWithString: labelWithString)
        translatesAutoresizingMaskIntoConstraints = false
    }

    convenience init(_ attributedString: NSAttributedString) {
        self.init(labelWithAttributedString: MarkdownTextfield.forceLeftToRight(attributedString))
        translatesAutoresizingMaskIntoConstraints = false
    }

    // we know the content to display should be left-to-right, so we force it to avoid displayed it right-to-left
    static func forceLeftToRight(_ attributedString: NSAttributedString) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.baseWritingDirection = .leftToRight
        let forced = NSMutableAttributedString(attributedString: attributedString)
        forced.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: forced.length))
        return forced
    }
}
