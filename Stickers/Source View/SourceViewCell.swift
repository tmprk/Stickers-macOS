//
//  SourceViewCell.swift
//  Stickers
//
//  Created by Timothy Park on 4/18/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class SourceViewCell: NSTableCellView, NSTextFieldDelegate {
    
    private var onUpdateSession: ((String)->Void)?
    
    let textfield: Textfield = {
        let textfield = Textfield(frame: .zero)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.lineBreakMode = .byClipping
        textfield.cell?.isScrollable = false
        textfield.cell?.wraps = false
        textfield.isEditable = true
        textfield.isSelectable = true
        return textfield
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textfield)
        let textfieldConstraints = [
            textfield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Styles.labelInsets.left),
            textfield.topAnchor.constraint(equalTo: topAnchor, constant: Styles.labelInsets.top),
            textfield.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Styles.labelInsets.right),
            textfield.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Styles.labelInsets.bottom)
        ]
        NSLayoutConstraint.activate(textfieldConstraints)
        textfield.delegate = self
    }
    
    func set(title: String, onUpdateSession: @escaping ((String) -> Void)) {
        self.textfield.stringValue = title
        self.onUpdateSession = onUpdateSession
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        onUpdateSession?(textfield.stringValue)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
