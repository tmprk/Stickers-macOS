//
//  CollectionViewItem.swift
//  Stickers
//
//  Created by Timothy Park on 4/21/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    
    let yourViewBorder = CAShapeLayer()
    static var identifier = NSUserInterfaceItemIdentifier(String(describing: self))
    
    var image: Image! {
        didSet {
            // layeredImageView.imagePath = image.url.path
            (view as? LayeredImageView)?.imagePath = image.url.path
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.view.layer?.backgroundColor = isSelected ? NSColor.gray.cgColor : NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        }
    }
    
    // let stickerView: NSImageView = {
    //     let stickerView = NSImageView()
    //     stickerView.translatesAutoresizingMaskIntoConstraints = false
    //     stickerView.imageScaling = .scaleProportionallyDown
    //     return stickerView
    // }()
    
    override func loadView() {
        let container = LayeredImageView()
        self.view = container
        self.view.wantsLayer = true
        
        // self.view.addSubview(stickerView)
        // let stickerViewConstraints = [
        //     stickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
        //     stickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
        //     stickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
        //     stickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4)
        // ]
        // NSLayoutConstraint.activate(stickerViewConstraints)
    }
    
    // override func viewDidLoad() {
    //     super.viewDidLoad()
    //     fillGradientLayer()
    // }
    // 
    // override func viewWillLayout() {
    //     fillGradientLayer()
    // }
    //
    // func fillGradientLayer() {
    //     yourViewBorder.strokeColor = NSColor.systemGray.cgColor
    //     yourViewBorder.lineWidth = 3
    //     yourViewBorder.masksToBounds = true
    //     yourViewBorder.lineDashPattern = [10, 7]
    //     yourViewBorder.frame = view.bounds
    //     yourViewBorder.fillColor = nil
    //     yourViewBorder.path = NSBezierPath(roundedRect: view.bounds, xRadius: 6, yRadius: 6).cgPath
    //     self.view.layer?.addSublayer(yourViewBorder)
    // }
    //
    // private func updateBorderLayer() {
    //     yourViewBorder.frame = view.bounds
    //     yourViewBorder.path = NSBezierPath(roundedRect: view.bounds, xRadius: 6, yRadius: 6).cgPath
    // }
    //
    // override func viewDidLayout() {
    //     super.viewDidLayout()
    //     updateBorderLayer()
    // }
    
}
