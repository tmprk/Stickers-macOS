//
//  ImageView.swift
//  Stickers
//
//  Created by Timothy Park on 7/31/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

enum DrawMode: Int {
    case freehand = 0
    case ellipse
    case square
}

class ImageView: NSImageView {
    
    public var mode: DrawMode!
    public var startPoint = CGPoint.zero
    public var currentDraggedPosition = CGPoint.zero
    public var currentOval: Oval?
    public let maskLayer = CAShapeLayer()
    
    public var color: NSColor? = UserDefaults.standard.color(forKey: "borderColor") {
        didSet {
            borderLayer.strokeColor = color?.cgColor
        }
    }
    
    public var thickness: CGFloat = GlobalSettings.borderWidth {
        didSet {
            borderLayer.lineWidth = thickness
        }
    }
    
    public var path: NSBezierPath = {
        let path = NSBezierPath()
        path.lineWidth = 1.0
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        path.windingRule = .nonZero
        path.setLineDash([12.0, 12.0], count: 2, phase: 0)
        return path
    }()
    
    public var dashedLayer: CAShapeLayer = {
        let dashedLayer = CAShapeLayer()
        dashedLayer.lineCap = .round
        dashedLayer.lineWidth = 3.0
        // dashedLayer.fillRule = .evenOdd
        dashedLayer.fillColor = NSColor.clear.cgColor
        dashedLayer.strokeColor = NSColor.white.cgColor
        dashedLayer.lineDashPattern = [8, 6]
        return dashedLayer
    }()
    
    public var borderLayer: CAShapeLayer = {
        let borderLayer = CAShapeLayer()
        borderLayer.lineJoin = .round
        borderLayer.lineCap = .round
        borderLayer.strokeColor = UserDefaults.standard.color(forKey: "borderColor")?.cgColor
        return borderLayer
    }()
    
    var resultImage: NSImage?
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        switch mode {
        case .ellipse:
            if let oval = currentOval {
                oval.draw()
            }
        case .freehand, .square:
            return
        default:
            return
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        resetAllLayers()
        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.duration = 0.75
        dashAnimation.fromValue = 0.0
        dashAnimation.toValue = dashedLayer.lineDashPattern?.reduce(0) { $0 - $1.intValue } ?? 0
        dashAnimation.repeatCount = .infinity
        dashedLayer.add(dashAnimation, forKey: "linePhase")
        switch mode {
        case .freehand:
            startPoint = convert(event.locationInWindow, from: nil)
            path.move(to: startPoint)
        case .ellipse:
            startPoint = convert(event.locationInWindow, to: nil)
            currentOval = Oval(origin: startPoint)
        case .square:
            self.startPoint = self.convert(event.locationInWindow, from: nil)
            layer?.addSublayer(dashedLayer)
        default:
            return
        }
        layer?.sublayers?.removeAll()
        layer?.mask = nil
        layer?.addSublayer(dashedLayer)
        needsDisplay = true
    }
    
    public override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        switch mode {
        case .freehand:
            path.line(to: convert(event.locationInWindow, from: nil))
            dashedLayer.path = path.cgPath
        case .ellipse:
            currentDraggedPosition = convert(event.locationInWindow, to: nil)
            let size = makeSize()
            if let oval = currentOval {
                oval.size = size
                dashedLayer.path = oval.path.cgPath
            }
        case .square:
            let point: NSPoint = self.convert(event.locationInWindow, from: nil)
            let tempPath = NSBezierPath()
            tempPath.move(to: startPoint)
            tempPath.line(to: NSPoint(x: self.startPoint.x, y: point.y))
            tempPath.line(to: point)
            tempPath.line(to: NSPoint(x:point.x,y:self.startPoint.y))
            tempPath.close()
            path = tempPath
            dashedLayer.path = tempPath.cgPath
        default:
            return
        }
        needsDisplay = true
    }
    
    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        switch mode {
        case .freehand:
            path.line(to: startPoint)
            dashedLayer.path = path.cgPath
        case .ellipse:
            currentDraggedPosition = convert(event.locationInWindow, to: nil)
            let size = makeSize()
            if let oval = currentOval {
                oval.size = size
                path = oval.path
                dashedLayer.path = oval.path.cgPath
            }
        case .square:
            break
        default:
            return
        }
        dashedLayer.removeFromSuperlayer()
        
        let shapePathSize = path.cgPath.boundingBoxOfPath.size
        if (shapePathSize.width > 10 && shapePathSize.height > 10) {
            maskLayer.path = path.cgPath
            
            // create an overlay of whole image and add dark tint
            let imageBoundsPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            let fillLayer = CAShapeLayer()
            fillLayer.path = imageBoundsPath.cgPath
            fillLayer.fillRule = .evenOdd
            fillLayer.fillColor = NSColor.black.cgColor
            fillLayer.opacity = 0.65
            layer?.addSublayer(fillLayer)
            
            // set border layer path and add to layer
            borderLayer.path = path.cgPath
            layer?.addSublayer(borderLayer)
            
            // add cutout portion to layer
            let cutoutLayer = CALayer()
            cutoutLayer.frame = layer!.bounds
            if let image = image {
                var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
                cutoutLayer.backgroundColor = NSColor.clear.cgColor
                cutoutLayer.contents = imageRef
            }
            cutoutLayer.mask = maskLayer
            layer?.addSublayer(cutoutLayer)
        } else {
            dashedLayer.path = nil
            clearPath()
        }
    }
    
    public func renderImage(completion: (Bool) -> ()) {
        // process image with stroke effect
        if maskLayer.path != nil {
            let size = path.cgPath.boundingBoxOfPath.size
            let image = NSImage(size: size)
            guard let rep = NSBitmapImageRep.init(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return }
            
            image.addRepresentation(rep)
            image.lockFocus()
            
            let ctx = NSGraphicsContext.current?.cgContext
            ctx?.saveGState()
            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            ctx!.clear(rect)
            ctx?.translateBy(x: -(path.bounds.midX - (size.width / 2)), y: -(path.bounds.midY - (size.height / 2)))
            path.addClip()
            layer?.draw(in: ctx!)
            
            ctx?.restoreGState()
            image.unlockFocus()
            
            let stroked = image.stroked(with: color ?? .white, thickness: (thickness / 2), quality: 10)
            resultImage = stroked
            completion(true)
        }
    }
    
    public func resetAllLayers() {
        clearPath()
        layer?.sublayers?.removeAll()
        maskLayer.path = nil
        borderLayer.path = nil
        dashedLayer.path = nil
        resultImage = nil
        needsDisplay = true
    }
    
    public func clearPath() {
        path.removeAllPoints()
    }
    
    func makeSize() -> CGSize {
        return CGSize(width: currentDraggedPosition.x - startPoint.x, height: currentDraggedPosition.y - startPoint.y)
    }
    
}
