//
//  HeaderCell.swift
//  Stickers
//
//  Created by Timothy Park on 7/24/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

protocol ExpandedCellDelegate:NSObjectProtocol{
    func topButtonTouched(section: Int)
    func deleteButtonSelected(section: Int)
}

// https://github.com/dwarvesf/session-buddy/blob/master/SessionBuddy%20Extension/Views/SessionListView/SessionCellView.swift
final class HeaderCell: NSView, NSCollectionViewSectionHeaderView {
    
    static var identifier = NSUserInterfaceItemIdentifier(String(describing: self))
    weak var delegate: ExpandedCellDelegate?
    public var section: Int!
    
    let titleLabel: Textfield = {
        let titleLabel = Textfield(labelWithString: "")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let countLabel: Textfield = {
        let countLabel = Textfield(labelWithString: "")
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        return countLabel
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        
        addSubview(titleLabel)
        addSubview(countLabel)
        
        let labelConstraints = [
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Styles.labelInsets.right),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Styles.labelInsets.left),
            titleLabel.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: Styles.labelInsets.right),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(labelConstraints)
        
        let clickRecogniser = NSClickGestureRecognizer(target: self, action: #selector(singleClick))
        clickRecogniser.numberOfClicksRequired = 1
        addGestureRecognizer(clickRecogniser)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func singleClick(_ sender: Any?){
        delegate!.topButtonTouched(section: section)
    }
    
}
