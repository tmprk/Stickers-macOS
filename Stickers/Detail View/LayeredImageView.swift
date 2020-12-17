//
//  LayeredImageView.swift
//  Stickers
//
//  Created by Timothy Park on 8/3/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import AppKit
import QuartzCore

// https://github.com/seido/testCollectionViewPerformance/blob/master/testCollectionViewPerformance/LayerdImageView.swift
class LayeredImageView: NSView {
    
    var imageLayer: CALayer? = nil
    
    var imagePath: String? {
        didSet {
            weak var ws = self;
            if(oldValue != self.imagePath) {
                self.layer?.sublayers?.removeAll()
            }
            let adjustedBounds = self.bounds.insetBy(dx: 10, dy: 10)
            let w = adjustedBounds.width
            let h = adjustedBounds.height
            let path = self.imagePath
            let l = CALayer()
            
            DispatchQueue(label: "LayeredImageView.image", attributes: DispatchQueue.Attributes.concurrent).async {
                if let wself = ws {
                    if(wself.imagePath == path) {
                        DispatchQueue.main.async {
                            let image = wself.reseizeImage(path: path!, width: Int(w), height: Int(h))
                            
                            if let wself = ws {
                                if(wself.imagePath == path) {
                                    l.contents = image;
                                    l.contentsGravity = .resizeAspect
                                    wself.imageLayer = l
                                    
                                    wself.layer?.sublayers?.removeAll()
                                    l.frame = (wself.layer?.bounds.insetBy(dx: 3, dy: 3))!
                                    
                                    wself.layer?.addSublayer(l)
                                    wself.layer?.masksToBounds = true
                                    wself.layer?.cornerRadius = 6
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.imageLayer?.frame = (self.layer?.bounds)!
        CATransaction.commit()
    }
    
    func reseizeImage(path:String, width:Int, height:Int) -> CGImage? {
        let s = self.window?.screen ?? NSScreen.main
        let f = s?.backingScaleFactor ?? CGFloat(1.0)
        
        let w = Int(CGFloat(width)*f)
        let h = Int(CGFloat(height)*f)
        
        let url = NSURL(fileURLWithPath: path)
        let org = CGImageSourceCreateWithURL(url, nil);
        
        let thumb = CGImageSourceCreateThumbnailAtIndex(org!, 0, NSDictionary(dictionary:[
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceThumbnailMaxPixelSize: NSNumber(value: Swift.max(w,h))
        ]))
        return thumb
    }
    
    // override func hitTest(_ point: NSPoint) -> NSView? {
    //     var view = super.hitTest(point)
    //     if view == self {
    //         repeat {
    //             view = view!.superview
    //         } while view != nil && !(view is NSCollectionView)
    //     }
    //     return view;
    // }
    
}
