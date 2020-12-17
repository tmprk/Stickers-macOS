//
//  SplitViewController.swift
//  Stickers
//
//  Created by Timothy Park on 4/18/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController, NSToolbarDelegate {
    
    private let splitViewResorationIdentifier = "io.cachedseed.restorationId:SplitViewController"
    
    lazy var sourceController = SourceController()
    lazy var detailController = DetailController()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        return .zero
    }
    
}


extension SplitViewController {
    
    private func setupView() {
        splitView.dividerStyle = .thin
        splitView.autosaveName = NSSplitView.AutosaveName(splitViewResorationIdentifier)
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)
        sourceController.view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        detailController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 400).isActive = true
        // view.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 400).isActive = true
    }
    
    private func setupLayout() {
        let sourceList = NSSplitViewItem(viewController: sourceController)
        sourceList.canCollapse = false
        sourceList.holdingPriority = NSLayoutConstraint.Priority(NSLayoutConstraint.Priority.defaultHigh.rawValue)
        addSplitViewItem(sourceList)
        
        let detailView = NSSplitViewItem(viewController: detailController)
        detailView.canCollapse = false
        addSplitViewItem(detailView)
    }
    
}
